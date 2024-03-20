# ZDB-Statistiken für FID und SSG

## Prepare

+ update MongoDB 
  + title and holdings
  + libraries
+ add new FIDs to `script/lib/ZDB/FID.pm`
+ update list of ILL libraries in `script/lib/ZDB/ILL.pm`

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
git add ..
git commit -m 'add stats for 2023'
git push origin master
```

Check website https://jorol.github.io/fid-ssg-stats
