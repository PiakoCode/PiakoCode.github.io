# Go-tricks

#Go #trick

- go*程序* 网络代理

```go
// 设置代理
var (
	proxyUrl, err = url.Parse("http://127.0.0.1:7890")

	client = http.Client{
		Transport: &http.Transport{
			Proxy: http.ProxyURL(proxyUrl),
		},
	}
)
```


命令行加载 

```go
go func() {
	fmt.Print("\033[?25l") // 隐藏光标
	c := [4]byte{'\\', '|', '/', '-'}
	i := 0
	for {
		if i == 4 {
			i = 0
		}
		fmt.Print("\b") // 退格
		fmt.Printf("%c", c[i])
		time.Sleep(time.Millisecond * 100)
		i++
	}
}()
fmt.Print("\b\n\033[?25h") // 恢复显示光标
```

![[Picture/Peek 2023-07-06 14-17.gif]]


获取当前时间，并转换为字符串

```go
package main

import (
    "fmt"
    "time"
)

func main() {
    now := time.Now()
    formattedTime := now.Format("2006-01-02 15:04:05")
    fmt.Println("当前时间：", formattedTime)
}

```