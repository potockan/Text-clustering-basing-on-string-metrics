# Ryciaczkowe:
dbSendQuery(con,"
create index
myIndex
on
CPosts (ConversationID)
")
# myIndex - nazwa indeksu
# CPosts - naznwa tabeli
# ConversationID - nazwa kolumny

Select Id,PostTypeId,ConversationID,Body
from CPosts
INDEXED BY myIndex
where CPosts.ConversationID between %s and %s