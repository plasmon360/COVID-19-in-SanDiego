#!/bin/zsh
NOW=$(date +"%m-%d-%Y")
WEBSITE=$HOME/Desktop/juluribk_website/plasmon360.github.io
ROOT=$HOME/Covid19_Sandiego_Zipcode_Plotting_Bokeh/
cd $ROOT

CASES_JSON_FILE=$ROOT/Data/Total_Count/all_dates_count_df.json 
DEATHS_JSON_FILE=$ROOT/Data/Deaths_by_demographics/all_dates_deaths_df.json 

CASES_JSON_FILETIME_BEFORE=$(stat $CASES_JSON_FILE -c %Y)
DEATHS_JSON_FILETIME_BEFORE=$(stat $DEATHS_JSON_FILE -c %Y)

echo "$(date) : Getting data from San diego County"
jupyter nbconvert --to notebook --inplace --execute Get_Sandiego_County_Data.ipynb
jupyter nbconvert --to notebook --inplace --execute Get_deaths_by_demographics.ipynb

CASES_JSON_FILETIME_AFTER=$(stat $CASES_JSON_FILE -c %Y)
DEATHS_JSON_FILETIME_AFTER=$(stat $DEATHS_JSON_FILE -c %Y)
CASES_TIMEDIFF=$(expr $CASES_JSON_FILETIME_AFTER - $CASES_JSON_FILETIME_BEFORE)
DEATHS_TIMEDIFF=$(expr $DEATHS_JSON_FILETIME_AFTER - $DEATHS_JSON_FILETIME_BEFORE)
#
# Check if JSON_FILE's are updated and if updated proceed to update webpage
if [ $CASES_TIMEDIFF -gt 0 ]  || [ $DEATHS_TIMEDIFF -gt 0 ]; then
    echo "COUNTY UPDATED THEIR PDF"
    echo "Executing jupyter notebook to generate standalone html"
    jupyter nbconvert --to notebook --inplace --execute Bokeh_Covid19_visualization.ipynb
    LAST_HTML=$(ls -Art $ROOT/HTML_outputs/C*.html | tail -n 1)
    echo "Copying $LAST_HTML to pelican"
    cp $LAST_HTML ../Desktop/juluribk_website/plasmon360.github.io/content/articles/Misc/Covid19.html
    echo "Addng and Commit to github"
    git add -A && git commit -a -m "Updated for $NOW"
    echo "Pushing"
    git push
    cd $WEBSITE
    echo "Adding changes and commiting  to static sebsite"
    git add -A && git commit -a -m "Updated covid19 post $NOW"
    echo "Pushing Static Website"
    git push
    source venv/bin/activate
    echo "Make githubio website"
    make github-quiet

else
    echo "COUNTY DID NOT UPDATE THEIR PDF"
fi



