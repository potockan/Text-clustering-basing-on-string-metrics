
library(stringi)

# s <- "\\verb|foczka|  $\\xrightarrow{trans.\\ z\\ i\\ k}$"# \\verb|fockza| $\\xrightarrow{trans.\\ c\\i\\ k}$ \\verb|fokcza| $\\xrightarrow{trans.\\ o\\i\\ k}$ \\verb|fkocza| $\\xrightarrow{us.\\ f}$ \\verb|kocza| $\\xrightarrow{us.\\ c}$ \\verb|koza| $\\xrightarrow{wst.\\ k}$ \\verb|kozak|."
# 
# 
# 
# stri_replace_all_regex(s, "( [^$&&^ &&\\p{L}]{1,2}) ", "$1~")
# 


s <- readLines("./LaTeX/praca1.tex")


s1 <- stri_replace_all_regex(s, "( [\\p{L}]{1,2}) ", "$1~")

cat(s1, file = "./LaTeX/praca_regex.tex", sep = "\n")
# have manually remove tildes from tikzpicture!
