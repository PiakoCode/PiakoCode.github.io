# Cargo
#rust

## Command

```shell
cargo new
```

```shell
cargo run
```


测试(默认`tests`目录)

```shell
cargo test
```

[测试的组织结构 - Rust 程序设计语言 简体中文版](https://rust.bootcss.com/ch11-03-test-organization.html)

```shell
cargo test --lib # 只测试lib
```


build 二进制文件

```shell
cargo build
```


```shell
cargo search # 查找package
```

```shell
cargo doc    # 生成项目文档
```

>[!note]
>
>在项目开头(如lib.rs), 添加`#![deny(missing_docs)]`, 强制所有公共项目都有文档注释
>ref: [Documentation - Rust API Guidelines](https://rust-lang.github.io/api-guidelines/documentation.html)
## Package Layout

[Package Layout - The Cargo Book](https://doc.rust-lang.org/cargo/guide/project-layout.html)

```
.
├── Cargo.lock
├── Cargo.toml
├── src/
│   ├── lib.rs
│   ├── main.rs
│   └── bin/
│       ├── named-executable.rs
│       ├── another-executable.rs
│       └── multi-file-executable/
│           ├── main.rs
│           └── some_module.rs
├── benches/
│   ├── large-input.rs
│   └── multi-file-bench/
│       ├── main.rs
│       └── bench_module.rs
├── examples/
│   ├── simple.rs
│   └── multi-file-example/
│       ├── main.rs
│       └── ex_module.rs
└── tests/
    ├── some-integration-tests.rs
    └── multi-file-test/
        ├── main.rs
        └── test_module.rs

```

默认可执行文件为 `main.rs` ，其他在 `src/bin/` 目录下

## Files

`cargo.toml`

```toml
[package]
name = "kvs"                            # 项目名称
version = "0.1.0"                       # 项目版本
edition = "2021"                        # rust版本
authors = ["Piako <1163312641@qq.com>"] # 作者
# See more keys and their definitions at https://doc.rust-lang.org/cargo/reference/manifest.html

[dev-dependencies]
assert_cmd = "0.11.0"
predicates = "1.0.0"

```


 
## Third Party Tools

- [cargo-edit: A utility for managing cargo dependencies from the command line.](https://github.com/killercup/cargo-edit)

允许通过从文件中修改 `Cargo.toml` 文件来添加。删除和升级依赖项

```shell
cargo add
cargo rm
cargo upgrade
```