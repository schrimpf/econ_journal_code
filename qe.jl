using Cascadia, Gumbo, HTTP, LibCURL

mainurl="https://qeconomics.org/ojs/index.php/qe/issue/archive"
mainhttp = HTTP.get(mainurl) |> x->x.body |> String |> parsehtml
umes = eachmatch(Cascadia.textRegexSelector(r"Volume \d+, Issue"),mainhttp.root)
links = eachmatch(Selector("a"),mainhttp.root)
# only first page of issues (to 2015, but that's enough)
issues = filter(l->try
                  occursin(r"issue/view/\d+", l.attributes["href"])
                catch
                  false
                end, links)

function supplementurls(issueurl)
  h = HTTP.get(issueurl) |> x->x.body |> String |> parsehtml
  wb = eachmatch(Selector(".action"),h.root)
  urls = Vector{String}(undef,0)
  for b ∈ wb
    m = eachmatch(Cascadia.textRegexSelector(r"Code and Data"), b)
    (length(m) > 0) || continue
    url = eachmatch(Selector("a"),m[1])[1].attributes["href"]
    push!(urls,url)
  end
  return(urls)
end


function savesupplement(url; maxbytes=1_500_000_000, # QE ignores --range anyway ...
                        cache=replace(url,r".+index.php" => ".")*".zip", refresh=false)
  cachepath = splitpath(cache)[1:(end-1)] |> joinpath |> normpath
  mkpath(cachepath)
  if (isfile(cache) && !refresh)
    @warn cache*" exists, not redownloading."
    return(url=url, zipfile=cache)
  end
  sizecmd=`curl -s -L -I $url`
  txt=Base.read(sizecmd) |> String
  size=parse(Int,match(r"Content-Length: (\d+)",txt).captures[1])
  if (size>maxbytes)
    @warn "$url supplement is $size, skipping"
    Base.run(`touch $cache`)
    return(url=url,zipfile=cache)
  end
  cmd = `curl -o $cache -L $url`
  Base.run(cmd)
  return(url=url, zipfile=cache)
end

for issue ∈ issues
  # only download 2020 and later
  length(eachmatch(Cascadia.textRegexSelector(r"202\d"), issue)) > 0 || continue
  urls = supplementurls(issue.attributes["href"])
  res = [savesupplement(url) for url ∈ urls]
end

jlfiles=[]
for (root, dir, files) ∈ walkdir("./qe")
  for file ∈ files
    filepath = joinpath(root,file)
    try
      out = read(Cmd(`unzip -l $filepath`,ignorestatus=true), String)
      em = eachmatch(r"(\.[a-zA-Z0-9_]+)\n",out)
      for m ∈ em
        if (m.captures[1] == ".jl")
          push!(jlfiles,filepath)
          println("yes .jl file in $filepath")
          break
        end
      end
      println("no .jl file in $filepath")
    catch
      println("Failed to read $filepath")
    end
  end
end
