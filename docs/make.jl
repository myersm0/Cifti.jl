using Cifti
using Documenter

DocMeta.setdocmeta!(Cifti, :DocTestSetup, :(using Cifti); recursive=true)

makedocs(;
    modules=[Cifti],
    authors="Michael Myers",
    repo="https://github.com/myersm0/Cifti.jl/blob/{commit}{path}#{line}",
    sitename="Cifti.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://myersm0.github.io/Cifti.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/myersm0/Cifti.jl",
    devbranch="main",
)
