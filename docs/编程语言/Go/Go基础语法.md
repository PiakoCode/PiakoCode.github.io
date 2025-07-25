windo# Golang基础语法

#go #基础


[A Tour of Go](https://go.dev/tour/list)
*代码：*[golang/tour: [mirror] A Tour of Go (github.com)](https://github.com/golang/tour)
通过以下指令查看Go的工作目录

```powershell
go env GOPATH
```

交叉编译
```shell
# Windows amd64
CGO_ENABLED=0 GOOS=windows  GOARCH=amd64  go build .


```
## 基础
### Hello,World!

```go
package main // 必须

// 导入其他包裹
import (
    "fmt"	// 输入输出
)

// 主函数
fun main() { 
    fmt.Println("Hello, Wolrd!")
}
```



## 定义变量

定义的变量必须被使用，否则将会报错

```go
var a int 		// 定义整型， 默认值为0
var b string 	// 定义字符串，默认为空字符串

// 其他定义方法
a := x
b := "hi"
```



## 逻辑判断

```go
if a > 1  {
	fmt.Println("bigger than 1")
} else if a < 0 {
	fmt.Println("less than 0")
} else {
	fmt.Println("something else")
}

if a > 1 && a < 10 {
	fmt.Println("Right")
}
```

switch的一个case中可以支持多个相，并且支持比较的逻辑判断
不需要写break
```go
switch i {
	case 0,2:
		t.Log("Even")
	case 1,3:
		t.Log("Odd")
	default:
		t.Log("it is not 0-3")
}

for i:=0;i<5;i++ {
		switch {
		case i%2 == 0:
			t.Log("Even")
		case i%2 != 0:
			t.Log("Odd")
		default:
			t.Log("unknow")
		}
	}
```

## 数组

### 定义数组

数组长度不可变

```go
//定义数组
var a [3] int

a := [3]int{1,2,3}
a := [...]int{1,2,3}

// 定义切片
a := []int{1,2,3}

// 修改数组组中元素的值
a[1] = 9


```

### 切片

切片的长度可变
![](../../Algorithm/Picture/Pasted%20image%2020221217194803.png)
![](../../Algorithm/Picture/Pasted%20image%2020221217201342.png)
```go
a := []int{1,2,3,4}
a = append(a,10) // 结尾添加值为10的变量
//len每次加1
//len>原有cap时，cap=cap*2,创建新的连续存储空间（不是在原有基础上增加）
```

原理：切片*创建*一个新的长度**翻倍**的数组，将旧数组的值拷贝到新数组中，并添加新值，释放旧数组所占内存。

len - 数组可访问的长度
cap - 数组实际的容量
cap >= len

数组之间可以比较
元组之间不能比较，只能和nil比较

## 映射

类似于词典

```go
//初始化映射
numbers := make(map[string]int)

//映射不固定大小
numbers["one"] = 1
numbers["two"] = 2

//删除关键词
delete(numbers, "one")
```

## 字符串
go中的字符串本质是不可变的byte切片

string默认为 ""
![](../../Algorithm/Picture/Pasted%20image%2020221218210143.png)
![](../../Algorithm/Picture/Pasted%20image%2020221218205327.png)

## 循环判断

go 语言中没有while循环

```go
for i := 0; i < 5; i++ {
	fmt.Println(i)
} 
```

但可以通过for循环间接实现

```go
i := 0
for ; i<5; {
	fmt.println(i)
	i++
}

// 无限循环
for {
    fmt.println(i)
    i++
}
```

for循环遍历元组、映射

```go
a := []int{1,2,3,4,5}
for k, v := range a {
	fmt.Println(k, v)
}

for k, v := range numbers {
	fmt.Println(k, v)
}
```

## 函数

### 定义函数

```go
func add(x int, y int) int {
	return x + y
}
```

可以不返回值，也可以返回多个值

```go
func do_math(x int, y int) (int,int) {
	return x+y, x*y
}
```

还可以返回一个函数（闭包）

### 函数的闭包
闭包是一个函数值，它引用了其函数体之外的变量。该函数可以访问并赋予其引用的变量的值，换句话说，该函数被这些变量“绑定”在一起。

例如，函数 `adder` 返回一个闭包。每个闭包都被绑定在其各自的 `sum` 变量上。
```go

func adder() func(int) int {
	sum := 0
	return func(x int) int {
		sum += x
		return sum
	}
}

func main() {
	pos, neg := adder(), adder()
	for i := 0; i < 10; i++ {
		fmt.Println(
			pos(i),
			neg(-2*i),
		)
	}
}
```

使用函数的闭包实现斐波那契数列
```go
// 返回一个“返回int的函数”
func fibonacci() func() int {
	v1,v2:=0,1
	return func() int {
		ans:=v1
		v1,v2=v2,v1+v2
		return ans
	}
}

func main() {
	f := fibonacci()
	for i := 0; i < 10; i++ {
		fmt.Println(f())
	}
}
```
## 指针

```go
n := 0
add(&n)
fmt.Println(n)

func add(n *int) {
	*n = *n + 1
}
```

## 自定义数据类型

go语言并非完全的面向对象语言，没有类

```go
// 定义结构体
type cat struct {
    name string
    age int
}

func main() {
    cat1 := cat{name: "kitty", age: 3}
    cat1.age=4
    fmt.Println(cat1)
}
```

可以给自定义类型创建方法

```go
type MyFloat float64

func (n MyFloat) show() {
	fmt.Println(n)
}

func main() {
    var a MyFloat = 1.5
    a.show()
}
//同样可以使用指针
```

![](../../Algorithm/Picture/Pasted%20image%2020221219165611.png)

vscode 错误：无法安装div ，解决方法：设置GOARCH=amd64

## Go的测试方法
文件名为xxx_test.go
测试函数命名方式为 Test+Xxx
```go
import "testing"

func TestFirst(t *testing.T) {
    t.Log("My first try!")
}
```

go语言变量类型没有隐式转换。例如，int32的变量a不能直接赋值给int64的变量b，必须将a强制转换为int64


![](../../Algorithm/Picture/Pasted%20image%2020221216194007.png)

## defer
![](../../Algorithm/Picture/Pasted%20image%2020221217195123.png)

```go
package main

import "fmt"

func main() {
	defer fmt.Println("world")

	fmt.Println("hello")
}
/*
output:

hello
world

*/
```
![](../../Algorithm/Picture/Pasted%20image%2020221217195318.png)

## 方法和接口
### 方法

### 定义方法
方法就是一类带特殊的 **接收者** 参数的函数。

方法接收者在它自己的参数列表内，位于 `func` 关键字和方法名之间。

在此例中，`Abs` 方法拥有一个名为 `v`，类型为 `Vertex` 的接收者。

```go
type Vertex struct {
	X, Y float64
}

func (v Vertex) Abs() float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}

func main() {
	v := Vertex{3, 4}
	fmt.Println(v.Abs())
}
```

### 方法即函数

记住：方法只是个带接收者参数的函数。

现在这个 `Abs` 的写法就是个正常的函数，功能并没有什么变化。

```go
type Vertex struct {
	X, Y float64
}

func Abs(v Vertex) float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}

func main() {
	v := Vertex{3, 4}
	fmt.Println(Abs(v))
}
```

### 非结构体方法
你也可以为非结构体类型声明方法。

在此例中，我们看到了一个带 `Abs` 方法的数值类型 `MyFloat`。

你只能为在同一包内定义的类型的接收者声明方法，而不能为其它包内定义的类型（包括 `int` 之类的内建类型）的接收者声明方法。

（译注：就是接收者的类型定义和方法声明必须在同一包内；不能为内建类型声明方法。）

```go

type MyFloat float64

func (f MyFloat) Abs() float64 {
	if f < 0 {
		return float64(-f)
	}
	return float64(f)
}

func main() {
	f := MyFloat(-math.Sqrt2)
	fmt.Println(f.Abs())
}
```

### 指针接收者声明方法
你可以为指针接收者声明方法。

这意味着对于某类型 `T`，接收者的类型可以用 `*T` 的文法。（此外，`T` 不能是像 `*int` 这样的指针。）

例如，这里为 `*Vertex` 定义了 `Scale` 方法。

指针接收者的方法可以修改接收者指向的值（就像 `Scale` 在这做的）。由于方法经常需要修改它的接收者，指针接收者比值接收者更常用。

试着移除第 16 行 `Scale` 函数声明中的 `*`，观察此程序的行为如何变化。

若使用值接收者，那么 `Scale` 方法会对原始 `Vertex` 值的副本进行操作。（对于函数的其它参数也是如此。）`Scale` 方法必须用指针接受者来更改 `main` 函数中声明的 `Vertex` 的值。

```go
type Vertex struct {
	X, Y float64
}

func (v Vertex) Abs() float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}

func (v *Vertex) Scale(f float64) {
	v.X = v.X * f
	v.Y = v.Y * f
}

func main() {
	v := Vertex{3, 4}
	v.Scale(10)
	fmt.Println(v.Abs())
}
```

### 将方法重写为函数

```go
type Vertex struct {
	X, Y float64
}

func Abs(v Vertex) float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}

func Scale(v *Vertex, f float64) {
	v.X = v.X * f
	v.Y = v.Y * f
}

func main() {
	v := Vertex{3, 4}
	Scale(&v, 10)
	fmt.Println(Abs(v))
}
```

### 方法与指针重定向

你大概会注意到带指针参数的函数必须接受一个指针：
```go
var v Vertex
ScaleFunc(v, 5)  // 编译错误！
ScaleFunc(&v, 5) // OK
```

而以指针为接收者的方法被调用时，接收者既能为值又能为指针：

```go
var v Vertex
v.Scale(5)  // OK
p := &v
p.Scale(10) // OK

```
对于语句 `v.Scale(5)`，即便 `v` 是个值而非指针，带指针接收者的方法也能被直接调用。 也就是说，由于 `Scale` 方法有一个指针接收者，为方便起见，Go 会将语句 `v.Scale(5)` 解释为 `(&v).Scale(5)`。

```go
type Vertex struct {
	X, Y float64
}

func (v *Vertex) Scale(f float64) {
	v.X = v.X * f
	v.Y = v.Y * f
}

func ScaleFunc(v *Vertex, f float64) {
	v.X = v.X * f
	v.Y = v.Y * f
}

func main() {
	v := Vertex{3, 4}
	v.Scale(2)
	ScaleFunc(&v, 10)

	p := &Vertex{4, 3}
	p.Scale(3)
	ScaleFunc(p, 8)

	fmt.Println(v, p)
}
```

同样的事情也发生在相反的方向。

接受一个值作为参数的函数必须接受一个指定类型的值：

```go
var v Vertex
fmt.Println(AbsFunc(v))  // OK
fmt.Println(AbsFunc(&v)) // 编译错误！
```

而以值为接收者的方法被调用时，接收者既能为值又能为指针：

```go
var v Vertex
fmt.Println(v.Abs()) // OK
p := &v
fmt.Println(p.Abs()) // OK
```

这种情况下，方法调用 `p.Abs()` 会被解释为 `(*p).Abs()`。

### 选择值或指针作为接收者

使用指针接收者的原因有二：
*首先*，方法能够修改其接收者指向的值。
*其次*，这样可以避免在每次调用方法时复制该值。若值的类型为大型结构体时，这样做会更加高效。

在本例中，`Scale` 和 `Abs` 接收者的类型为 `*Vertex`，即便 `Abs` 并不需要修改其接收者。

通常来说，所有给定类型的方法都应该有值或指针接收者，但并不应该二者混用。（我们会在接下来明白为什么。）

```go
type Vertex struct {
	X, Y float64
}

func (v *Vertex) Scale(f float64) {
	v.X = v.X * f
	v.Y = v.Y * f
}

func (v *Vertex) Abs() float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}

func main() {
	v := &Vertex{3, 4}
	fmt.Printf("Before scaling: %+v, Abs: %v\n", v, v.Abs())
	v.Scale(5)
	fmt.Printf("After scaling: %+v, Abs: %v\n", v, v.Abs())
}
```

### 接口

![](../../Algorithm/Picture/Pasted%20image%2020221220125904.png)

### 定义接口

**接口类型** 是由一组方法签名定义的集合。

接口类型的变量可以保存任何实现了这些方法的值。

**注意:** 示例代码的 22 行存在一个错误。由于 `Abs` 方法只为 `*Vertex` （指针类型）定义，因此 `Vertex`（值类型）并未实现 `Abser`。

```go
type Abser interface {
	Abs() float64
}

func main() {
	var a Abser
	f := MyFloat(-math.Sqrt2)
	v := Vertex{3, 4}

	a = f  // a MyFloat 实现了 Abser
	a = &v // a *Vertex 实现了 Abser

	// 下面一行，v 是一个 Vertex（而不是 *Vertex）
	// 所以没有实现 Abser。
	a = v

	fmt.Println(a.Abs())
}

type MyFloat float64

func (f MyFloat) Abs() float64 {
	if f < 0 {
		return float64(-f)
	}
	return float64(f)
}

type Vertex struct {
	X, Y float64
}

func (v *Vertex) Abs() float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}
```

### 接口与隐式实现

类型通过实现一个接口的所有方法来实现该接口。既然无需专门显式声明，也就没有“implements”关键字。
隐式接口从接口的实现中解耦了定义，这样接口的实现可以出现在任何包中，无需提前准备。

因此，也就无需在每一个实现上增加新的接口名称，这样同时也鼓励了明确的接口定义。

```go
type I interface {
	M()
}

type T struct {
	S string
}

// 此方法表示类型 T 实现了接口 I，但我们无需显式声明此事。
func (t T) M() {
	fmt.Println(t.S)
}

func main() {
	var i I = T{"hello"}
	i.M()
}
```

### 接口值

接口也是值。它们可以像其它值一样传递。

接口值可以用作函数的参数或返回值。

在内部，接口值可以看做包含值和具体类型的元组：
(value, type)

接口值保存了一个具体底层类型的具体值。

接口值调用方法时会执行其底层类型的同名方法。

```go
type I interface {
	M()
}

type T struct {
	S string
}

func (t *T) M() {
	fmt.Println(t.S)
}

type F float64

func (f F) M() {
	fmt.Println(f)
}

func main() {
	var i I

	i = &T{"Hello"}
	describe(i)    // (&{Hello}, *main.T)
	i.M()          // Hello

	i = F(math.Pi)
	describe(i)    // (3.141592653589793, main.F)
	i.M()          // 3.141592653589793
}

func describe(i I) {
	fmt.Printf("(%v, %T)\n", i, i)
}
```

### 底层值为 nil 的接口值

即便接口内的具体值为 nil，方法仍然会被 nil 接收者调用。

在一些语言中，这会触发一个空指针异常，但在 Go 中通常会写一些方法来优雅地处理它（如本例中的 `M` 方法）。

**注意:** 保存了 nil 具体值的接口其自身并不为 nil。
```go
func (t *T) M() {
	if t == nil {
		fmt.Println("<nil>")
		return
	}
	fmt.Println(t.S)
}

// (<nil>, *main.T)
// <nil>
```

### nil 接口值

nil 接口值既不保存值也不保存具体类型。

为 nil 接口调用方法会产生运行时错误，因为接口的元组内并未包含能够指明该调用哪个 **具体** 方法的类型。

```go
type I interface {
	M()
}

func main() {
	var i I
	describe(i)
	i.M()
}

func describe(i I) {
	fmt.Printf("(%v, %T)\n", i, i)
}
```


### 空接口

指定了零个方法的接口值被称为 *空接口：*

interface{}

空接口可保存任何类型的值。（因为每个类型都至少实现了零个方法。）

空接口被用来处理未知类型的值。例如，`fmt.Print` 可接受类型为 `interface{}` 的任意数量的参数。

```go
func main() {
	var i interface{}
	describe(i)

	i = 42
	describe(i)

	i = "hello"
	describe(i)
}

func describe(i interface{}) {
	fmt.Printf("(%v, %T)\n", i, i)
}

// (<nil>, <nil>)
// (42, int)
// (hello, string)
```

### 类型

#### 类型断言

**类型断言** 提供了访问接口值底层具体值的方式。

t := i.(T)

该语句断言接口值 `i` 保存了具体类型 `T`，并将其底层类型为 `T` 的值赋予变量 `t`。

若 `i` 并未保存 `T` 类型的值，该语句就会触发一个panic。

为了 **判断** 一个接口值是否保存了一个特定的类型，类型断言可返回两个值：其底层值以及一个报告断言是否成功的布尔值。

t, ok := i.(T)

若 `i` 保存了一个 `T`，那么 `t` 将会是其底层值，而 `ok` 为 `true`。

否则，`ok` 将为 `false` 而 `t` 将为 `T` 类型的零值，程序并不会产生panic。

请注意这种语法和读取一个映射时的相同之处。

```go
func main() {
	var i interface{} = "hello"

	s := i.(string)
	fmt.Println(s) //hello

	s, ok := i.(string)
	fmt.Println(s, ok) //hello true

	f, ok := i.(float64)
	fmt.Println(f, ok) //0 false

	f = i.(float64) // 报错(panic)
	fmt.Println(f)
}
```

#### 类型选择

**类型选择** 是一种按顺序从几个类型断言中选择分支的结构。

类型选择与一般的 switch 语句相似，不过类型选择中的 case 为类型（而非值）， 它们针对给定接口值所存储的值的类型进行比较。

```go
switch v := i.(type) {
case T:
    // v 的类型为 T
case S:
    // v 的类型为 S
default:
    // 没有匹配，v 与 i 的类型相同
}
```

类型选择中的声明与类型断言 `i.(T)` 的语法相同，只是具体类型 `T` 被替换成了关键字 `type`。

此选择语句判断接口值 `i` 保存的值类型是 `T` 还是 `S`。在 `T` 或 `S` 的情况下，变量 `v` 会分别按 `T` 或 `S` 类型保存 `i` 拥有的值。在默认（即没有匹配）的情况下，变量 `v` 与 `i` 的接口类型和值相同。
```go
func do(i interface{}) {
	switch v := i.(type) {
	case int:
		fmt.Printf("Twice %v is %v\n", v, v*2)
	case string:
		fmt.Printf("%q is %v bytes long\n", v, len(v))
	default:
		fmt.Printf("I don't know about type %T!\n", v)
	}
}

func main() {
	do(21)
	do("hello")
	do(true)
}
```

## 函数、结构体、结构体成员可见性

Go语言没有像其它语言一样有`public`、`protected`、`private`等访问控制修饰符，它是通过**首字母大小写**来控制可见性的，

如果定义的常量、变量、类型、接口、结构、函数等的名称是大写字母开头表示能被其它包访问或调用（相当于`public`），非大写开头就只能在包内使用（相当于`private`，变量或常量也可以下划线开头）



## Stringer

[`fmt`](https://go-zh.org/pkg/fmt/) 包中定义的 [`Stringer`](https://go-zh.org/pkg/fmt/#Stringer) 是最普遍的接口之一。

```go
type Stringer interface {
    String() string
}
```

`Stringer` 是一个可以用字符串描述自己的类型。`fmt` 包（还有很多包）都通过此接口来打印值。

```go
type Person struct {
	Name string
	Age  int
}

func (p Person) String() string {
	return fmt.Sprintf("%v (%v years)", p.Name, p.Age)
}

func main() {
	a := Person{"Arthur Dent", 42}
	z := Person{"Zaphod Beeblebrox", 9001}
	fmt.Println(a, z)
}

// Arthur Dent (42 years) Zaphod Beeblebrox (9001 years)
```
### 练习：Stringer

通过让 `IPAddr` 类型实现 `fmt.Stringer` 来打印点号分隔的地址。

例如，`IPAddr{1, 2, 3, 4}` 应当打印为 `"1.2.3.4"`。

```go
package main

import "fmt"

type IPAddr [4]byte
/*
func(I IPAddr) String() string {
	return fmt.Sprintf("%v.%v.%v.%v",I[0],I[1],I[2],I[3])
}
*/
func main() {
	hosts := map[string]IPAddr{
		"loopback":  {127, 0, 0, 1},
		"googleDNS": {8, 8, 8, 8},
	}
	for name, ip := range hosts {
		fmt.Printf("%v: %v\n", name, ip)
	}
}

```

## 错误
Go 程序使用 `error` 值来表示错误状态。

与 `fmt.Stringer` 类似，`error` 类型是一个内建接口：

```go
type error interface {
    Error() string
}
```

（与 `fmt.Stringer` 类似，`fmt` 包在打印值时也会满足 `error`。）

通常函数会返回一个 `error` 值，调用的它的代码应当判断这个错误是否等于 `nil` 来进行错误处理。

```go
i, err := strconv.Atoi("42")
if err != nil {
    fmt.Printf("couldn't convert number: %v\n", err)
    return
}
fmt.Println("Converted integer:", i)
```

`error` 为 nil 时表示成功；非 nil 的 `error` 表示失败。

```go
type MyError struct {
	When time.Time
	What string
}

func (e *MyError) Error() string {
	return fmt.Sprintf("at %v, %s",
		e.When, e.What)
}

func run() error {
	return &MyError{
		time.Now(),
		"it didn't work",
	}
}

func main() {
	if err := run(); err != nil {
		fmt.Println(err)
	}
}
```
### 练习：错误
[练习：错误](https://tour.go-zh.org/methods/20)
从[之前的练习](https://tour.go-zh.org/flowcontrol/8)中复制 `Sqrt` 函数，修改它使其返回 `error` 值。

`Sqrt` 接受到一个负数时，应当返回一个非 nil 的错误值。复数同样也不被支持。

创建一个新的类型

type ErrNegativeSqrt float64

并为其实现

func (e ErrNegativeSqrt) Error() string

方法使其拥有 `error` 值，通过 `ErrNegativeSqrt(-2).Error()` 调用该方法应返回 `"cannot Sqrt negative number: -2"`。

**注意:** 在 `Error` 方法内调用 `fmt.Sprint(e)` 会让程序陷入死循环。可以通过先转换 `e` 来避免这个问题：`fmt.Sprint(float64(e))`。这是为什么呢？

修改 `Sqrt` 函数，使其接受一个负数时，返回 `ErrNegativeSqrt` 值。

```go
package main

import (
	"fmt"
)

type ErrNegativeSqrt float64

func Sqrt(x float64) (float64, error) {
	z := x
	if x < 0 {
		return 0, ErrNegativeSqrt(x)
	} else {
		for {
			z -= (z*z - x) / (2 * z)
			t := z*z - x
			if t < 0 {
				t = -t
			}
			if t < 1e-10 {
				break
			}
		}
		return z, nil
	}
}

func (e ErrNegativeSqrt) Error() string {
	return fmt.Sprintf("cannot Sqrt negative number: %v\n", float64(e))
}

func main() {
	fmt.Println(Sqrt(2))
	fmt.Println(Sqrt(-2))
}
```

## Reader
`io` 包指定了 `io.Reader` 接口，它表示从数据流的末尾进行读取。

Go 标准库包含了该接口的[许多实现](https://go-zh.org/search?q=Read#Global)，包括文件、网络连接、压缩和加密等等。

`io.Reader` 接口有一个 `Read` 方法：

func (T) Read(b []byte) (n int, err error)

`Read` 用数据填充给定的字节切片并返回填充的字节数和错误值。在遇到数据流的结尾时，它会返回一个 `io.EOF` 错误。

示例代码创建了一个 [`strings.Reader`](https://go-zh.org/pkg/strings/#Reader) 并以每次 8 字节的速度读取它的输出。
```go
package main

import (
	"fmt"
	"io"
	"strings"
)

func main() {
	r := strings.NewReader("Hello, Reader!")

	b := make([]byte, 8)
	for {
		n, err := r.Read(b)
		fmt.Printf("n = %v err = %v b = %v\n", n, err, b)
		fmt.Printf("b[:n] = %q\n", b[:n])
		if err == io.EOF {
			break
		}
	}
}
/*
n = 8 err = <nil> b = [72 101 108 108 111 44 32 82]
b[:n] = "Hello, R"
n = 6 err = <nil> b = [101 97 100 101 114 33 32 82]
b[:n] = "eader!"
n = 0 err = EOF b = [101 97 100 101 114 33 32 82]
b[:n] = ""
*/
```
### 练习：Reader

实现一个 `Reader` 类型，它产生一个 ASCII 字符 `'A'` 的无限流。
```go
package main
import "golang.org/x/tour/reader"
type MyReader struct{}
// TODO: 给 MyReader 添加一个 Read([]byte) (int, error) 方法
func (r MyReader) Read(b []byte) (int,error) {
	b[0] = 'A'
	return 1,nil
}

func main() {
	reader.Validate(MyReader{})
}
```

### 练习：rot13Reader

有种常见的模式是一个 [`io.Reader`](https://go-zh.org/pkg/io/#Reader) 包装另一个 `io.Reader`，然后通过某种方式修改其数据流。

例如，[`gzip.NewReader`](https://go-zh.org/pkg/compress/gzip/#NewReader) 函数接受一个 `io.Reader`（已压缩的数据流）并返回一个同样实现了 `io.Reader` 的 `*gzip.Reader`（解压后的数据流）。

编写一个实现了 `io.Reader` 并从另一个 `io.Reader` 中读取数据的 `rot13Reader`，通过应用 [rot13](http://en.wikipedia.org/wiki/ROT13) 代换密码对数据流进行修改。

`rot13Reader` 类型已经提供。实现 `Read` 方法以满足 `io.Reader`。

```go
package main

import (
	"io"
	"os"
	"strings"
)

type rot13Reader struct {
	r io.Reader
}

func trans(b byte) byte{
	switch {
		case b>='A'&&b<='M':
		b+=13
		case b>'M'&&b<='Z':
		b-=13
		case b>='a'&&b<='m':
		b+=13
		case b>'m'&&b<='z':
		b-=13
		
	}
	return b
}

func (myr rot13Reader) Read(b []byte) (int,error) {
	n,err:=myr.r.Read(b)
	for i:=0;i<n;i++ {
		b[i]=trans(b[i])
	}
	return n,err
}

func main() {
	s := strings.NewReader("Lbh penpxrq gur pbqr!")
	r := rot13Reader{s}
	io.Copy(os.Stdout, &r)
}

```

## 图像

[`image`](https://go-zh.org/pkg/image/#Image) 包定义了 `Image` 接口：
```go
package image

type Image interface {
    ColorModel() color.Model
    Bounds() Rectangle
    At(x, y int) color.Color
}
`````
**注意:** `Bounds` 方法的返回值 `Rectangle` 实际上是一个 [`image.Rectangle`](https://go-zh.org/pkg/image/#Rectangle)，它在 `image` 包中声明。

（请参阅[文档](https://go-zh.org/pkg/image/#Image)了解全部信息。）

`color.Color` 和 `color.Model` 类型也是接口，但是通常因为直接使用预定义的实现 `image.RGBA` 和 `image.RGBAModel` 而被忽视了。这些接口和类型由 [`image/color`](https://go-zh.org/pkg/image/color/) 包定义。

```go
import (
	"fmt"
	"image"
)

func main() {
	m := image.NewRGBA(image.Rect(0, 0, 100, 100))
	fmt.Println(m.Bounds())
	fmt.Println(m.At(0, 0).RGBA())
}
```


### 练习：图像

还记得之前编写的[图片生成器](https://tour.go-zh.org/moretypes/18) 吗？我们再来编写另外一个，不过这次它将会返回一个 `image.Image` 的实现而非一个数据切片。

定义你自己的 `Image` 类型，实现[必要的方法](https://go-zh.org/pkg/image/#Image)并调用 `pic.ShowImage`。

`Bounds` 应当返回一个 `image.Rectangle` ，例如 `image.Rect(0, 0, w, h)`。

`ColorModel` 应当返回 `color.RGBAModel`。

`At` 应当返回一个颜色。上一个图片生成器的值 `v` 对应于此次的 `color.RGBA{v, v, 255, 255}`。

```go
package main

import (
	"golang.org/x/tour/pic"
	"image/color"
    "image"
)
type Image struct{}

func (i Image) ColorModel() color.Model {
	return color.RGBAModel
}

func (i Image) Bounds() image.Rectangle {
	return image.Rect(0, 0, 200, 200)
}

func (i Image) At(x,y int) color.Color {
	return color.RGBA{uint8(x), uint8(y), uint8(255), uint8(255)}
}

func main() {
	m := Image{}
	pic.ShowImage(m)
}
```

output:
![|left](../../Algorithm/Picture/Pasted%20image%2020221230221653.png)
## 并发
### goroutine

Go 程（goroutine）是由 Go 运行时管理的轻量级线程。

go f(x, y, z)

会启动一个新的 Go 程并执行

f(x, y, z)

`f`, `x`, `y` 和 `z` 的求值发生在当前的 Go 程中，而 `f` 的执行发生在新的 Go 程中。

Go 程在相同的地址空间中运行，因此在访问共享的内存时必须进行同步。[`sync`](https://go-zh.org/pkg/sync/) 包提供了这种能力，不过在 Go 中并不经常用到，因为还有其它的办法（见下一页）。

```go
func say(s string) {
	for i := 0; i < 5; i++ {
		time.Sleep(100 * time.Millisecond)
		fmt.Println(s)
	}
}

func main() {
	go say("world")
	say("hello")
}

```

### 信道

信道是带有类型的管道，你可以通过它用信道操作符 `<-` 来发送或者接收值。

```go
ch <- v    // 将 v 发送至信道 ch。
v := <-ch  // 从 ch 接收值并赋予 v。
```

（“箭头”就是数据流的方向。）

和映射与切片一样，信道在使用前必须创建：

```go
ch := make(chan int)
```

默认情况下，发送和接收操作在另一端准备好之前都会阻塞。这使得 Go 程可以在没有显式的锁或竞态变量的情况下进行同步。

以下示例对切片中的数进行求和，将任务分配给两个 Go 程。一旦两个 Go 程完成了它们的计算，它就能算出最终的结果。
```go
func sum(s []int, c chan int) {
	sum := 0
	for _, v := range s {
		sum += v
	}
	c <- sum // 将和送入 c
}

func main() {
	s := []int{7, 2, 8, -9, 4, 0}

	c := make(chan int)
	go sum(s[:len(s)/2], c)
	go sum(s[len(s)/2:], c)
	x, y := <-c, <-c // 从 c 中接收

	fmt.Println(x, y, x+y)
}
// -5 17 12
```

### 带缓冲的信道

信道可以是 _带缓冲的_。将缓冲长度作为第二个参数提供给 `make` 来初始化一个带缓冲的信道：

ch := make(chan int, 100)

仅当信道的缓冲区填满后，向其发送数据时才会阻塞。当缓冲区为空时，接受方会阻塞。

修改示例填满缓冲区，然后看看会发生什么。
```go
package main

import "fmt"

func main() {
	ch := make(chan int, 2) // 1时会出现错误，>=2时正常运行
	ch <- 1
	ch <- 2
	fmt.Println(<-ch) // 1
	fmt.Println(<-ch) // 2
}
```

## range 和 close

发送者可通过 `close` 关闭一个信道来表示没有需要发送的值了。接收者可以通过为接收表达式分配第二个参数来测试信道是否被关闭：若没有值可以接收且信道已被关闭，那么在执行完

v, ok := <-ch

之后 `ok` 会被设置为 `false`。

循环 `for i := range c` 会不断从信道接收值，直到它被关闭。

*注意：* 只有发送者才能关闭信道，而接收者不能。向一个已经关闭的信道发送数据会引发程序恐慌（panic）。

*还要注意：* 信道与文件不同，通常情况下无需关闭它们。只有在必须告诉接收者不再有需要发送的值时才有必要关闭，例如终止一个 `range` 循环。

```go
func fibonacci(n int, c chan int) {
	x, y := 0, 1
	for i := 0; i < n; i++ {
		c <- x
		x, y = y, x+y
	}
	close(c)
}

func main() {
	c := make(chan int, 10)
	go fibonacci(cap(c), c)
	for i := range c {
		fmt.Println(i)
	}
}

```

## select 语句

`select` 语句使一个 Go 程可以等待多个通信操作。

`select` 会阻塞到某个分支可以继续执行为止，这时就会执行该分支。当多个分支都准备好时会随机选择一个执行。
```go
func fibonacci(c, quit chan int) {
	x, y := 0, 1
	for {
		select {
		case c <- x:
			x, y = y, x+y
		case <-quit:
			fmt.Println("quit")
			return
		}
	}
}

func main() {
	c := make(chan int)
	quit := make(chan int)
	go func() {
		for i := 0; i < 10; i++ {
			fmt.Println(<-c)
		}
		quit <- 0
	}()
	fibonacci(c, quit)
}
```

### 默认选择

当 `select` 中的其它分支都没有准备好时，`default` 分支就会执行。

为了在尝试发送或者接收时不发生阻塞，可使用 `default` 分支：

```go
select {
case i := <-c:
    // 使用 i
default:
    // 从 c 中接收会阻塞时执行
}
```

```go
func main() {
	tick := time.Tick(100 * time.Millisecond)
	boom := time.After(500 * time.Millisecond)
	for {
		select {
		case <-tick:
			fmt.Println("tick.")
		case <-boom:
			fmt.Println("BOOM!")
			return
		default:
			fmt.Println("    .")
			time.Sleep(50 * time.Millisecond)
		}
	}
}

```

### 练习：等价二叉查找树

不同二叉树的叶节点上可以保存相同的值序列。例如，以下两个二叉树都保存了序列 `1，1，2，3，5，8，13`。

![](https://tour.go-zh.org/content/img/tree.png)

在大多数语言中，检查两个二叉树是否保存了相同序列的函数都相当复杂。 我们将使用 Go 的并发和信道来编写一个简单的解法。

本例使用了 `tree` 包，它定义了类型：

```go
type Tree struct {
    Left  *Tree
    Value int
    Right *Tree
}
```
**1.** 实现 `Walk` 函数。

**2.** 测试 `Walk` 函数。

函数 `tree.New(k)` 用于构造一个随机结构的已排序二叉查找树，它保存了值 `k`, `2k`, `3k`, ..., `10k`。

创建一个新的信道 `ch` 并且对其进行步进：

go Walk(tree.New(1), ch)

然后从信道中读取并打印 10 个值。应当是数字 `1, 2, 3, ..., 10`。

**3.** 用 `Walk` 实现 `Same` 函数来检测 `t1` 和 `t2` 是否存储了相同的值。

**4.** 测试 `Same` 函数。

`Same(tree.New(1), tree.New(1))` 应当返回 `true`，而 `Same(tree.New(1), tree.New(2))` 应当返回 `false`。

`Tree` 的文档可在[这里](https://godoc.org/golang.org/x/tour/tree#Tree)找到。

```go
import (
	"fmt"
	"golang.org/x/tour/tree"
)

// Walk 步进 tree t 将所有的值从 tree 发送到 channel ch。
func Walk(t *tree.Tree, ch chan int) {
	if t.Left != nil {
		Walk(t.Left, ch)
	}
	ch <- t.Value
	if t.Right != nil {
		Walk(t.Right, ch)
	}
	return
}

// Same 检测树 t1 和 t2 是否含有相同的值。
func Same(t1, t2 *tree.Tree) bool {
	ch1, ch2 := make(chan int), make(chan int)
	go Walk(t1, ch1)
	go Walk(t2, ch2)
	if <-ch1 == <-ch2 {
		return true
	} else {
		return false
	}
}

func main() {
	ch := make(chan int)
	t := tree.New(1)
	go Walk(t, ch)
	
	for i := 0; i < 10; i++ {
		fmt.Println(<-ch)
	}
	
	fmt.Println(Same(tree.New(1), tree.New(1)))
}
```



### sync.Mutex

我们已经看到信道非常适合在各个 Go 程间进行通信。

但是如果我们并不需要通信呢？比如说，若我们只是想保证每次只有一个 Go 程能够访问一个共享的变量，从而避免冲突？

这里涉及的概念叫做 *互斥（mutual*exclusion）* ，我们通常使用 *互斥锁（Mutex）* 这一数据结构来提供这种机制。

Go 标准库中提供了 [`sync.Mutex`](https://go-zh.org/pkg/sync/#Mutex) 互斥锁类型及其两个方法：

-   `Lock`
-   `Unlock`

我们可以通过在代码前调用 `Lock` 方法，在代码后调用 `Unlock` 方法来保证一段代码的互斥执行。参见 `Inc` 方法。

我们也可以用 `defer` 语句来保证互斥锁一定会被解锁。参见 `Value` 方法。
```go
package main

import (
	"fmt"
	"sync"
	"time"
)

// SafeCounter 的并发使用是安全的。
type SafeCounter struct {
	v   map[string]int
	mux sync.Mutex
}

// Inc 增加给定 key 的计数器的值。
func (c *SafeCounter) Inc(key string) {
	c.mux.Lock()
	// Lock 之后同一时刻只有一个 goroutine 能访问 c.v
	c.v[key]++
	c.mux.Unlock()
}

// Value 返回给定 key 的计数器的当前值。
func (c *SafeCounter) Value(key string) int {
	c.mux.Lock()
	// Lock 之后同一时刻只有一个 goroutine 能访问 c.v
	defer c.mux.Unlock()
	return c.v[key]
}

func main() {
	c := SafeCounter{v: make(map[string]int)}
	for i := 0; i < 1000; i++ {
		go c.Inc("somekey")
	}

	time.Sleep(time.Second)
	fmt.Println(c.Value("somekey")) // 1000                                                                        
}
```

### 练习：Web 爬虫
 
在这个练习中，我们将会使用 Go 的并发特性来并行化一个 Web 爬虫。

修改 `Crawl` 函数来并行地抓取 URL，并且保证不重复。

_提示_：你可以用一个 map 来缓存已经获取的 URL，但是要注意 map 本身并不是并发安全的！
```go
// Copyright 2012 The Go Authors.  All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// +build ignore

package main

import (
	"errors"
	"fmt"
	"sync"
)

type Fetcher interface {
	// Fetch returns the body of URL and
	// a slice of URLs found on that page.
	Fetch(url string) (body string, urls []string, err error)
}

// fetched tracks URLs that have been (or are being) fetched.
// The lock must be held while reading from or writing to the map.
// See https://golang.org/ref/spec#Struct_types section on embedded types.
var fetched = struct {
	m map[string]error
	sync.Mutex
}{m: make(map[string]error)}

var loading = errors.New("url load in progress") // sentinel value

// Crawl uses fetcher to recursively crawl
// pages starting with url, to a maximum of depth.
func Crawl(url string, depth int, fetcher Fetcher) {
	if depth <= 0 {
		fmt.Printf("<- Done with %v, depth 0.\n", url)
		return
	}

	fetched.Lock()
	if _, ok := fetched.m[url]; ok {
		fetched.Unlock()
		fmt.Printf("<- Done with %v, already fetched.\n", url)
		return
	}
	// We mark the url to be loading to avoid others reloading it at the same time.
	fetched.m[url] = loading
	fetched.Unlock()

	// We load it concurrently.
	body, urls, err := fetcher.Fetch(url)

	// And update the status in a synced zone.
	fetched.Lock()
	fetched.m[url] = err
	fetched.Unlock()

	if err != nil {
		fmt.Printf("<- Error on %v: %v\n", url, err)
		return
	}
	fmt.Printf("Found: %s %q\n", url, body)
	done := make(chan bool)
	for i, u := range urls {
		fmt.Printf("-> Crawling child %v/%v of %v : %v.\n", i, len(urls), url, u)
		go func(url string) {
			Crawl(url, depth-1, fetcher)
			done <- true
		}(u)
	}
	for i, u := range urls {
		fmt.Printf("<- [%v] %v/%v Waiting for child %v.\n", url, i, len(urls), u)
		<-done
	}
	fmt.Printf("<- Done with %v\n", url)
}

func main() {
	Crawl("https://golang.org/", 4, fetcher)

	fmt.Println("Fetching stats\n--------------")
	for url, err := range fetched.m {
		if err != nil {
			fmt.Printf("%v failed: %v\n", url, err)
		} else {
			fmt.Printf("%v was fetched\n", url)
		}
	}
}

// fakeFetcher is Fetcher that returns canned results.
type fakeFetcher map[string]*fakeResult

type fakeResult struct {
	body string
	urls []string
}

func (f *fakeFetcher) Fetch(url string) (string, []string, error) {
	if res, ok := (*f)[url]; ok {
		return res.body, res.urls, nil
	}
	return "", nil, fmt.Errorf("not found: %s", url)
}

// fetcher is a populated fakeFetcher.
var fetcher = &fakeFetcher{
	"https://golang.org/": &fakeResult{
		"The Go Programming Language",
		[]string{
			"https://golang.org/pkg/",
			"https://golang.org/cmd/",
		},
	},
	"https://golang.org/pkg/": &fakeResult{
		"Packages",
		[]string{
			"https://golang.org/",
			"https://golang.org/cmd/",
			"https://golang.org/pkg/fmt/",
			"https://golang.org/pkg/os/",
		},
	},
	"https://golang.org/pkg/fmt/": &fakeResult{
		"Package fmt",
		[]string{
			"https://golang.org/",
			"https://golang.org/pkg/",
		},
	},
	"https://golang.org/pkg/os/": &fakeResult{
		"Package os",
		[]string{
			"https://golang.org/",
			"https://golang.org/pkg/",
		},
	},
}
```

## 测试

test   以Test开头
基准测试 以Benchmark开头 
```go
func Ben
```

## 其他
可以通过`go install`命令获取网络上的包、或者第三方的依赖管理工具

## 命名规范

-   variable
    -   简洁胜于冗长
    -   缩略词全大写，但当其位于变量开头且不需要导出时，使用全小写
    -   变量距离其被使用的地方越远，则需要携带越多的上下文信息
    -   全局变量在其名字中需要更多的上下文信息，使得在不同地方可以轻易辨认出其含义

-   function
    -   函数名不携带包名的上下文信息，因为包名和函数名总是成对出现的
    -   函数名尽量简短
    -   当名为 foo 的包某个函数返回类型 Foo 时，可以省略类型信息而不导致歧义
    -   当名为 foo 的包某个函数返回类型 T 时（T 并不是 Foo），可以在函数名中加入类型信息

-   package
    -   只由小写字母组成。不包含大写字母和下划线等字符
    -   简短并包含一定的上下文信息。例如 schema、task 等
    -   不要与标准库同名。例如不要使用 sync 或者 strings

  

作者：青训营官方账号  
链接：https://juejin.cn/post/7188225875211452476  
来源：稀土掘金  
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。