
### 677 444 Polish words
### 41 087 == 705402 - 664315 English words
### 20 438 == 725840 - 705402 French words
### 21 117 == 746957 - 725840 German words

aa <- data.frame(jezyk = c("polski", "angielski", "niemiecki", "francuski"),
                 liczba = c("677 444", "41 087", "21 117", "20 438"))

aa[,1] <- as.character(aa[,1])
aa[,2] <- as.character(aa[,2])
aa <- rbind(aa, c("ogolem", "733 828"))

aa <- cbind(aa, procent = c(24.2, 1.5, 0.8, 0.7, 27.1))

xtable::xtable(aa)


# wykresy gdzie jest 3x13 slupkow - 
# po jednym na rozne licznosci zbioru, 
# po 3 na zbior.
# takich wykresow mozna zrobic od 3 do 6


