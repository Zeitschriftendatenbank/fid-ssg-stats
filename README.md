# ZDB-Statistiken für FID und SSG

## Prepare

+ update MongoDB
  + title and holdings
  + libraries
+ add new FIDs to `script/lib/ZDB/FID.pm` (see https://isil.staatsbibliothek-berlin.de/fid-kennzeichen)
+ update list of ILL libraries in `script/lib/ZDB/ILL.pm` (get list via command `$ zbd list_org_ill`)

## Create statistics

Run script from `script` directory:

```
cd script/
perl generate_stats.pl
```

## Publish statistiscs

Commit changes and push repository

```
cd ..
git add .
git commit -m 'add stats for {YEAR}'
git push origin master
```

Check website https://jorol.github.io/fid-ssg-stats
