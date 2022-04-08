using Cascadia, Gumbo, HTTP, LibCURL


mainurl="https://www.econometricsociety.org/publications/econometrica/browse/"
mainhttp = HTTP.get(mainurl) |> x->x.body |> String |> parsehtml
volumes = eachmatch(Selector(".volume"),mainhttp.root)
v = first(volumes)
issues = eachmatch(Selector("li"), v.parent) # only back to 1978 (that's plenty though)

function articleurls(issue; baseurl = "https://www.econometricsociety.org")
  issueurl = baseurl*eachmatch(Selector("a"),issue.children[1])[1].attributes["href"]
  h = HTTP.get(issueurl) |> x->x.body |> String |> parsehtml
  wb = eachmatch(Selector(".white_button"),h.root)
  urls = Vector{String}(undef,0)
  for b ∈ wb
    m = eachmatch(Cascadia.textRegexSelector(r"Supplement"), b)
    (length(m) > 0) || continue
    url = eachmatch(Selector("a"),m[1])[1].attributes["href"]
    push!(urls,url)
  end
  return(urls)
end


function savesupplement(url; bytes=15_000_000, cache="."*url*".zip", refresh=false,
                        baseurl="https://www.econometricsociety.org")
  cachepath = splitpath(cache)[1:(end-1)] |> joinpath |> normpath
  mkpath(cachepath)
  if (isfile(cache) && !refresh)
    @warn cache*" exists, not redownloading."
    return(url=url, zipfile=cache)
  end
  h = HTTP.get(baseurl*url) |> x->x.body |> String |> parsehtml
  wb = eachmatch(Selector(".green_button"),h.root)
  urls = Vector{String}(undef, 0)
  for b ∈ wb
    m = eachmatch(Cascadia.textRegexSelector(r"ZIP"), b)
    (length(m) > 0) || continue
    url = eachmatch(Selector("a"),m[1])[1].attributes["href"]
    push!(urls,url)
  end
  @warn length(urls)<=1 "Found multiple ZIP files in supplement"
  if length(urls)==0
    touch(cache)
    return(url=url, zipfile=cache)
  end
  zipurl = urls[1]
  # Strangely, --range is ignored every other request
  # Run an extra request if needed as a work around
  cmd = `curl -I --range -$bytes -L $zipurl`
  out = read(cmd, String)
  bytesremote =
    try
      parse(Int,match(r"content-length: (\d+)", out).captures[1])
    catch
      0
    end
  if (bytesremote==bytes)
    Base.run(cmd)
  end
  cmd = `curl -o $cache --range -$bytes -L $zipurl`
  println(cmd)
  Base.run(cmd)

  return(url=url, zipfile=cache)
end

for issue ∈ issues
  if match(r"20[12]",text(issue))!=nothing
    urls = articleurls(issue)
    res = [savesupplement(url) for url ∈ urls]
  end
end


jlfiles=[]
for (root, dir, files) ∈ walkdir("./publications")
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
