##My [Flexget](https://github.com/Flexget/Flexget) config

This is not a comprehensive feature list, and many settings were tuned to personal preference. It is also under constant development.

It currently does the following (ideally by this order):
* Populates the series database with a set interval (mainly to allow fresh starts of the series db)
* Purges the custom entry list for series, to allow full sync with the trakt series list
* Gets series from a trakt list and writes them to the custom entry list, and then looks up for their tvdb name, to have series names ready for kodi (since trakt v2 all series have the year in the name)
* Looks on the series download folder for .torrent files and adds them to transmission
* Looks for series on RSS feeds and downloads them
* Discovers and downloads series that don't have any download history or are missing (with a set interval because it should not happen often)
* Does the previous tasks, but this time for anime, using myanimelist as a list source instead
* Looks for movies in the drive and removes them from both the movie queue and the trakt list (this has a similar effect to the populate task for series db)
* Fills the movie queue with the movies in the trakt list
* Looks on the movies download folder for .torrent files and adds them to transmission
* Discovers and downloads 1080p movies and 720p movies (it only downloads 720p if the movie is not recent, where 1080p may not be available), and removes them from the trakt list if downloaded
* Looks on the download folders for series and movies, and moves them to the respective folder on the drive, while renaming it and adding it to the subtitle queue
* Does a similar thing for anime, with the exception of the subtitles, but also adding the filename to a file to allow anime renaming from an external program
* Downloads subtitles for the files in the subtitle queue
* Cleans torrents from transmission that have have been finished for 1 day, to allow checking transmission's webui for errors and alike
* Updates the trakt series list from the series in the library, meaning that manually downloaded series will be part of flexget's series search, with the exception of when the tv show has already ended (with an interval of 1 day, because it should not happen often)
* Finally, it will look if all the series currently in the trakt series list are still running, or have been canceled/ended, and if so, remove them from that list (with a big interval to avoid false positives)

It parses multiple RSS feeds for tv shows, searches thepiratebay for movies and missing tv shows, and nyaa for anime.

It also has Pushbullet notifications for all downloads and ended/canceled series, and the log_filter plugin (by [tarzasai](https://github.com/tarzasai/.flexget)) to filter some log messages that are unnecessary.

This was built based on multiple configurations and snippets over the time, with the help of [flexget's community](http://discuss.flexget.com/).


Depends:
--------

* flexget >= 2.2.0
* transmission-daemon
* transmissionrpc >= 0.11
* Linux


Installation
------------

* Clone this repository's contents into ~/.flexget
* Authenticate flexget with trakt: http://flexget.com/wiki/Plugins/trakt
* Create the folder structure according to example below (names inside brackets represent the secrets variable for next step)
* Rename secrets.yml.sample to secrets.yml and change the fields inside according to your accounts and system
* Create the trakt.tv lists accordingly
* Change the transmission port in config.yml (under transmission-settings)
* Alternative names, quality, begin episode and other series settings can be defined directly with the series plugin in the series.yml and anime.yml files, as shown in the sample files
* If you dont use any of the above files, you need to comment the respective includes (and possibly the templates) in config.yml
* If you plan on using the anime rename script, you will need to install and configure [kiara](https://github.com/jonybat/kiara/) and create the anime rename list file. If not just remove the lines marked in the move-anime task
* Finally, add the necessary files to configure flexget as a service (daemon). See: http://flexget.com/wiki/Daemon/Startup


Folder structure:
----------------
```
/mount/media                      (root)
............/downloads
....................../series     (downseries)
....................../anime      (downanime)
....................../movies     (downmovies)
............/series               (series)
............/anime                (anime)
............/movies               (movies)
```
