```go

module projectname 
或者
module github.com/yourusername/myapp // 模块路径


go 1.20  // 使用的Go版本

require (
    github.com/gin-gonic/gin v1.9.1  // 依赖项及其版本
    github.com/jinzhu/gorm v1.9.16
)

require (
    github.com/go-playground/validator/v10 v10.14.1 // indirect
    // 其他间接依赖...
)

// 可选：替换依赖
replace github.com/jinzhu/gorm => ./local/gorm  // 使用本地路径替换

// 可选：排除依赖
exclude github.com/gin-gonic/gin v1.9.0  // 排除特定版本
```