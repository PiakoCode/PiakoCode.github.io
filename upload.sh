#! /usr/bin/bash

# 笔记备份脚本
# 每周五-22点进行备份



BLUE='\033[1;34m'  # 蓝色
GREEN='\033[0;32m' # 绿色
NC='\033[0m'       # 恢复默认颜色

NOTE_PATH="$HOME/Data/markdown-note"

cd ${NOTE_PATH} || exit

echo -e "\n${BLUE}--------Start--------\n${NC}"
git status

git add .
echo -e "\n${GREEN}Add all files.\n${NC}"

LANG=zh_CN.UTF-8 git commit -m "$(date)"
echo -e "${GREEN}Commit complete.\n${NC}"

echo -e "${GREEN}git push gitee${NC}\n"
git push gitee main

echo -e "\n${BLUE}git push github${NC}\n"
git push github main

echo -e "\n${BLUE}git push github-page${NC}\n"
git push github-page main

echo -e "\n${BLUE}git push codeberg${NC}\n"
git push codeberg main



echo -e "${GREEN}-----Push Complete!-----\n${NC}"
