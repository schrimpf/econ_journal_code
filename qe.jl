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


function savesupplement(url; bytes=15_000_000, # QE ignores --range anyway ...
                        cache=replace(url,r".+index.php" => ".")*".zip", refresh=false)
  cachepath = splitpath(cache)[1:(end-1)] |> joinpath |> normpath
  mkpath(cachepath)
  if (isfile(cache) && !refresh)
    @warn cache*" exists, not redownloading."
    return(url=url, zipfile=cache)
  end
  cmd = `curl -I -o $cache --range -$bytes $url`
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
