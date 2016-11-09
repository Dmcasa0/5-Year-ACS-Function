### INPUT THE YEARS< TABLES< AND API KEY BELOW ###

#Change Years in paranthesis to the years desired
Years <- c(2010, 2011, 2012, 2013, 2014)
#Change the table names in the parenthesis to the tables desired
Tables <- c('B19101','B19001','B15002', 'B17010', 'B17021', 'B23007','B23009','B14002','B14005','B25070','B25091','B99103')
#Input your API Key Here:
api.key.install(key=" --- ") 



library(acs)
library(RODBC)
library(stringr)


for (t in Tables) {

ACS.Table <- t 
DF.List <- NULL

assign(paste(Tables[1], '.', '2014', sep = ''), acs.fetch(endyear=2014, span=5, geography=geo.make(state="KY",county="Jefferson",tract="*",block.group="*", check=T), table.number=Tables[1]))

for (i in Years) {
assign(paste(ACS.Table, '.', i, sep = ''), acs.fetch(endyear=i, span=5, geography=geo.make(state="KY",county="Jefferson",tract="*",block.group="*", check=T), table.number=ACS.Table))
assign(paste(ACS.Table, '.DF.', i, sep = ''), data.frame(geography(get(paste(ACS.Table, '.', i, sep = ''))),estimate(get(paste(ACS.Table, '.', i, sep = '')))))
df <- get(paste(ACS.Table, '.DF.', i, sep = ''))
df$Year <- i
df$FipsCode <- paste(
  str_pad(df$state, 2, pad = 0), 
  str_pad(df$county, 3, pad = 0), 
  str_pad(df$tract, 6, pad = 0), 
  str_pad(df$blockgroup, 1, pad = 0),
  sep = '')
assign(paste(ACS.Table, '.DF.', i, sep = ''), df)
DF.List <- c(DF.List, paste(ACS.Table, '.DF.', i, sep = ''))
###################  Shoule we drop Name and all the FIPS code components???  Don't need the data.###############################
}     
df <- NULL
i <- NULL

##NAMES MUST MATCH TO USE RBIND.  THIS WORKS ASSUMING ORDER IS OK . THIS METHOD IS LIKE UNION ALL IN SQL
df <- NULL
data.frame(df)
for (i in DF.List) {
  if  (is.null(df)) 
      {df <- get(i)} 
  else 
      {df <- rbind(as.matrix(df), as.matrix(get(i)))}
    }
df <- data.frame(df) 
##If Field Length longer than 128, need to truncate
x <- 1
for(i in names(df)){
  if(nchar(i) > 128){
    colnames(df)[x] <- substring(i, nchar(i) - 127, nchar(i))
    }
    x <- x + 1
  }

} #End For Table Loop



