
echo "# AMSR2" >> README.md

git init
git add README.md
git add .gitignore 
git commit -m "first commit"
git remote add origin git@github.com:yudong-tian/AMSR2.git
#git push -u origin master
git pull git@github.com:yudong-tian/AMSR2.git master
git push origin master

