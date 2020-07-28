using Documenter, Iex

CI_FLG = get(ENV, "CI", nothing) == "true"

makedocs(
    modules = [Iex],
    format = Documenter.HTML(
        prettyurls = CI_FLG
    ),
    sitename="IexJulia")


deploydocs(
    repo = "github.com/GodolphinCapitalManagement/Iex.git",
    push_preview = true,
)
