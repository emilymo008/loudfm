# require(RLastFM)
require(analyzelastfm)
require(dplyr)
require(stringr)
require(ggplot2)
require(lubridate)

# http://rcrastinate.blogspot.com/2019/01/10-years-of-playback-history-on-lastfm.html
# https://www.semidocumentedlife.com/post/monthly-audio-features-spotifyr/
# https://developer.spotify.com/documentation/web-api/reference/tracks/get-audio-features/

# https://developer.spotify.com/dashboard/applications
spotid <- 'hidden'
spotsc <- 'hidden'
  
# 
lastid <- 'hidden'
lastsc <- 'hidden'

# get lastfm data
l15 <- UserData$new("aznapple09", lastid, year = 2015)
l15 <- l15$data_table
l16 <- UserData$new("aznapple09", lastid, year = 2016)
l16 <- l16$data_table
l17 <- UserData$new("aznapple09", lastid, year = 2017)
l17 <- l17$data_table
l18 <- UserData$new("aznapple09", lastid, year = 2018)
l18 <- l18$data_table
scr <- rbind(l18, l17, l16, l15)

# get better date column
scr$timestamp <- parse_date_time(scr$datetext, "dmYHM")

# write.csv(scr, 'scr.csv')

require(spotifyr) # I start off using 1.1.0 from github, then downgrade because some features didn't work in the new version

Sys.setenv(SPOTIFY_CLIENT_ID = spotid)
Sys.setenv(SPOTIFY_CLIENT_SECRET = spotsc)
acc <- get_spotify_access_token()

# testing out spotifyr
plist <- get_user_playlists("1229909959")
testing <- as.data.frame(get_playlist_tracks(plist[8,]))
feats <- left_join(testing, get_track_audio_features(testing), by = 'track_uri')

# next steps: for just unique tracks in scr, search up all those tracks' uris with get_tracks, join uris to scr
tracks <- unique(scr[c("artist", "track")])
tracks$index <- 1:nrow(tracks)
tracks$track_uri = NA
for (i in 2:nrow(tracks)) {
  tryCatch(
    {
      tmp <- get_tracks(track_name = tracks$track[i], artist_name = tracks$artist[i])
      uri <- tmp$track_uri
      tracks$track_uri[i] <- uri
    },
    error = function(x) {
      tracks$track_uri[i] <- NA
    }
  )
}

# write.csv(tracks, 'tracks_d1.csv')
noid <- tracks[is.na(tracks$track_uri),] # check which tracks are unidentifiable from spotify, will exclude most from analysis

#### rules for cleaning up "unidentifiable" tracks that are actually identifiable ####
for (i in which(is.na(tracks$track_uri))) {
  t <- tracks$track[i]
  a <- tracks$artist[i]
  
  # if there's an open parenthesis, scrap that and all characters after it and try
  if (grepl('\\(', t)) {
    t <- unlist(strsplit(t, split = ' \\('))[1]
  }
    
  # if there's ' - ' followed by a digit in c(1, 2), scrap all that
  if (grepl(' - 1', t) | grepl(' - 2', t)) {
    t <- unlist(strsplit(t, split = ' -'))[1]
  }
  
  # some artists will need their own rules
  if (a == 'Luminous Orange') {
    a <- 'Luminousorange'
  }
  
  if (a == 'Alex G') {
    a <- '(Sandy) Alex G'
  }
  
  if (a == 'Julian Casablancas + The Voidz') {
    a <- 'The Voidz'
  }
  
  if (a == '少年ナイフ') {
    a <- 'Shonen Knife'
  }
  
  if (a == 'David Byrne & St. Vincent') {
    a <- 'David Byrne'
  }
  
  if (a == 'Boredoms' & grepl('\\(', t)) { 
    t <- gsub('\\(', '', t)
    t <- gsub('\\)', '', t)
  }
  
  if (a == '砂原良徳') {
    a <- 'Yoshinori Sunahara'
  }
  
  if (a == 'The Higher Intelligence Agency') {
    a <- 'Higher Intelligence Agency'
  }
  
  if (a == 'The Beach Boys') {
    t <- unlist(strsplit(t, split = ' -'))[1]
  }
  
  if (a == 'The Dismemberment Plan') {
    a <- 'Dismemberment Plan'
  }
  
  # some faye wong tracks
  if (t == 'Fen Lie') {
    t <- '分裂'
  }
  
  if (t == 'Duo Luo') {
    t <- '堕落'
  }
  
  if (t == 'Shi Yan') {
    t <- '誓言'
  }
  
  # after going through all rules, try lookup again
  tryCatch(
    {
      tmp <- get_tracks(track_name = t, artist_name = a)
      uri <- tmp$track_uri
      tracks$track_uri[i] <- uri
    },
    error = function(x) {
      tracks$track_uri[i] <- NA
    })
}
noid <- tracks[is.na(tracks$track_uri),]
nrow(noid)

write.csv(tracks, 'tracks_d2.csv')

nrow(tracks)
length(unique(tracks$track_uri)) # lots of duplicate tracks b/c of different versions

# table of unique uris and track features
uris <- as.data.frame(na.exclude(unique(tracks$track_uri)))
colnames(uris) <- 'track_uri'
# features <- get_track_audio_features(uris) 
# Error in handle_url(handle, url, ...) : could not find function "str_glue" 
# certain functions is not working but they worked on 1.0.0. so might have to downgrade:

# **** downgraded spotifyr (and also had to reinstall dplyr) ****

features <- get_track_audio_features(uris) 

#### cleaning ####

scr <- left_join(scr, tracks, by = c('track', 'artist'))
scr <- left_join(scr, features, by = 'track_uri')
scr$year <- year(scr$timestamp)
scr$month <- month(scr$timestamp)
scr$monthyear <- as.Date(paste(scr$year, scr$month, '01', sep = '-'))

write.csv(scr, 'scr2.csv')

scr <- scr[!(is.na(scr$track_uri) | is.na(scr$danceability)),]

bymonth <- aggregate(x = scr[,9:23], by = list(scr$monthyear), FUN = mean)
colnames(bymonth)[1] <- 'monthyear'
bymonth$month <- month(bymonth$monthyear)
bymonth$year <- year(bymonth$monthyear)

medbymonth <- aggregate(x = scr[,9:23], by = list(scr$monthyear), FUN = median)
colnames(medbymonth)[1] <- 'monthyear'
medbymonth$month <- month(medbymonth$monthyear)
medbymonth$year <- year(medbymonth$monthyear)

scrbymonth <- aggregate(x = scr$track_uri, by = list(scr$monthyear), FUN = length) # scrobbles by month, will be used for size of blocks

#### exploring ####
# aggregate median by month: (since track features are not normally distributed)
ggplot(data = medbymonth, aes(x = month, y = energy, color = as.factor(year))) + geom_point(size = 5, stroke = 0, alpha = 1)
ggplot(data = medbymonth, aes(x = month, y = danceability, color = as.factor(year))) + geom_point(size = 5, stroke = 0, alpha = 1) 
ggplot(data = medbymonth, aes(x = month, y = acousticness, color = as.factor(year))) + geom_point(size = 5, stroke = 0, alpha = 1)
ggplot(data = medbymonth, aes(x = month, y = valence, color = as.factor(year))) + geom_point(size = 5, stroke = 0, alpha = 1)
ggplot(data = medbymonth, aes(x = month, y = loudness, color = as.factor(year))) + geom_point(size = 5, stroke = 0, alpha = 1)
ggplot(data = medbymonth, aes(x = month, y = instrumentalness, color = as.factor(year))) + geom_point(size = 5, stroke = 0, alpha = 1)

# median loudness by month plot is interesting:
ggplot(data = medbymonth, aes(x = month, y = loudness, color = as.factor(year))) + geom_point(size = 5, stroke = 0, alpha = 1)



#### crunching ####

last <- lm(loudness ~ month + I(month^2) + month*year, data = scr)
summary(last)
plot(last2) # diagnostics are not ideal, but this isn't about modeling anyway
# note: year doesn't have a linear interaction with month as seen in the plot. It's probably more complex to use linear interaction with year; probably should model each year separately
last15_1 <- lm(loudness ~ month + I(month^2), data = scr[scr$year == 2015,])
summary(last15_1) # neg quadratic
last16_1 <- lm(loudness ~ month, data = scr[scr$year == 2016,])
summary(last16_1) # no trend
last17_1 <- lm(loudness ~ month + I(month^2), data = scr[scr$year == 2017,])
summary(last17_1) # neg quadratic
last18_1 <- lm(loudness ~ month, data = scr[scr$year == 2018,])
summary(last18_1) # pos linear trend


#### export ####
loud <- as.data.frame(cbind(1:nrow(scrbymonth), as.character(scrbymonth$x), medbymonth$loudness, medbymonth$month, medbymonth$year))
colnames(loud) <- c('block', 'quantity', 'transparency', 'month', 'year')
for(i in 1:nrow(loud)) {
  if(loud$year[i] == 2015) {
    loud$yrindex[i] = 1
  }
  else if(loud$year[i] == 2016) {
    loud$yrindex[i] = 2
  }
  else if(loud$year[i] == 2017) {
    loud$yrindex[i] = 3
  }
  else if(loud$year[i] == 2018) {
    loud$yrindex[i] = 4
  }
}

# write_json(loud, 'loudness.json')

