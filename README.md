- 编码批量转换
  
  ```shell
   find -name '*.java' -type f -print | xargs -i iconv -f GB18030 -t utf-8 {} -o {}
  ```
 
