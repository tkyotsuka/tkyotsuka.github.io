---
layout: post
title: "Rust最速マスターガイド：初心者から上級者まで完全攻略"
date: 2025-01-16
categories: [rust, programming, systems-programming]
---

# Rust最速マスターガイド：初心者から上級者まで完全攻略

このガイドでは、Rustプログラミング言語を効率的にマスターするための包括的なロードマップを提供します。基礎から応用まで、実践的なコード例とともに段階的に学習できるように構成されています。

## 目次

1. [Rustとは何か](#rustとは何か)
2. [開発環境のセットアップ](#開発環境のセットアップ)
3. [基本文法](#基本文法)
4. [所有権とボローイング](#所有権とボローイング)
5. [構造体とenum](#構造体とenum)
6. [エラーハンドリング](#エラーハンドリング)
7. [ジェネリクスとトレイト](#ジェネリクスとトレイト)
8. [ライフタイム](#ライフタイム)
9. [並行性と非同期プログラミング](#並行性と非同期プログラミング)
10. [実践プロジェクト](#実践プロジェクト)
11. [パフォーマンス最適化](#パフォーマンス最適化)
12. [エコシステムとベストプラクティス](#エコシステムとベストプラクティス)

## Rustとは何か

Rustは**メモリ安全性**と**並行性**を重視したシステムプログラミング言語です。C/C++と同等のパフォーマンスを提供しながら、メモリリークやデータ競合を防ぐコンパイル時チェックを行います。

### 主な特徴
- **ゼロコスト抽象化**：高レベルな機能でもパフォーマンスの損失なし
- **所有権システム**：ガベージコレクタなしでメモリ安全性を実現
- **型安全性**：コンパイル時にバグの多くを検出
- **関数型プログラミング**：イミュータブルデータと関数型スタイルをサポート

## 開発環境のセットアップ

### 1. Rustupのインストール

```bash
# Linux/macOS
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Windows
# https://rustup.rs/ からインストーラーをダウンロード
```

### 2. 開発ツールの確認

```bash
rustc --version    # Rustコンパイラ
cargo --version    # パッケージマネージャー
rustfmt --version  # コードフォーマッター
clippy --version   # リンター
```

### 3. 新しいプロジェクトの作成

```bash
cargo new hello_rust
cd hello_rust
cargo run
```

## 基本文法

### 変数と可変性

```rust
fn main() {
    // イミュータブル（不変）変数
    let x = 5;
    println!("x = {}", x);
    
    // ミュータブル（可変）変数
    let mut y = 5;
    y = 6;
    println!("y = {}", y);
    
    // 定数
    const MAX_POINTS: u32 = 100_000;
    
    // シャドーイング
    let spaces = "   ";
    let spaces = spaces.len();
}
```

### データ型

```rust
fn main() {
    // 整数型
    let a: i32 = 42;
    let b: u64 = 100;
    
    // 浮動小数点型
    let c: f64 = 3.14;
    
    // 真偽値型
    let d: bool = true;
    
    // 文字型
    let e: char = 'R';
    
    // タプル
    let tup: (i32, f64, u8) = (500, 6.4, 1);
    let (x, y, z) = tup;  // 分割代入
    
    // 配列
    let arr: [i32; 5] = [1, 2, 3, 4, 5];
    let first = arr[0];
}
```

### 関数

```rust
fn main() {
    let result = add(5, 3);
    println!("Result: {}", result);
    
    let doubled = double(10);
    println!("Doubled: {}", doubled);
}

fn add(x: i32, y: i32) -> i32 {
    x + y  // セミコロンなし = 式として返す
}

fn double(x: i32) -> i32 {
    return x * 2;  // return文を使用
}
```

### 制御フロー

```rust
fn main() {
    // if文
    let number = 6;
    if number % 4 == 0 {
        println!("divisible by 4");
    } else if number % 3 == 0 {
        println!("divisible by 3");
    } else {
        println!("not divisible by 4 or 3");
    }
    
    // if式
    let condition = true;
    let number = if condition { 5 } else { 6 };
    
    // loop
    let mut counter = 0;
    let result = loop {
        counter += 1;
        if counter == 10 {
            break counter * 2;
        }
    };
    
    // while
    let mut number = 3;
    while number != 0 {
        println!("{}!", number);
        number -= 1;
    }
    
    // for
    let arr = [10, 20, 30, 40, 50];
    for element in arr.iter() {
        println!("value: {}", element);
    }
    
    for number in (1..4).rev() {
        println!("{}!", number);
    }
}
```

## 所有権とボローイング

Rustの最も重要な概念である所有権システムを理解しましょう。

### 所有権の基本ルール

1. Rustの各値は**所有者**（owner）を持つ
2. 同時に存在できる所有者は1つだけ
3. 所有者がスコープを外れると、値は削除される

```rust
fn main() {
    {
        let s = String::from("hello");  // sが所有者
    }  // sがスコープを外れ、メモリが解放される
    
    // 所有権の移動（move）
    let s1 = String::from("hello");
    let s2 = s1;  // s1からs2に所有権が移動
    // println!("{}", s1);  // エラー！s1はもう使用できない
    println!("{}", s2);
    
    // クローン
    let s1 = String::from("hello");
    let s2 = s1.clone();  // 深いコピー
    println!("s1 = {}, s2 = {}", s1, s2);  // 両方使用可能
}
```

### 関数と所有権

```rust
fn main() {
    let s = String::from("hello");
    takes_ownership(s);  // 所有権が関数に移動
    // println!("{}", s);  // エラー！
    
    let x = 5;
    makes_copy(x);  // i32はCopyトレイトを実装しているため
    println!("{}", x);  // 問題なし
    
    let s1 = gives_ownership();
    let s2 = String::from("hello");
    let s3 = takes_and_gives_back(s2);
}

fn takes_ownership(some_string: String) {
    println!("{}", some_string);
}

fn makes_copy(some_integer: i32) {
    println!("{}", some_integer);
}

fn gives_ownership() -> String {
    let some_string = String::from("hello");
    some_string
}

fn takes_and_gives_back(a_string: String) -> String {
    a_string
}
```

### ボローイング（借用）

```rust
fn main() {
    let s1 = String::from("hello");
    let len = calculate_length(&s1);  // 参照を渡す
    println!("The length of '{}' is {}.", s1, len);
    
    // ミュータブルな参照
    let mut s = String::from("hello");
    change(&mut s);
    println!("{}", s);
}

fn calculate_length(s: &String) -> usize {  // 借用
    s.len()
}

fn change(some_string: &mut String) {
    some_string.push_str(", world");
}
```

### 参照のルール

```rust
fn main() {
    let mut s = String::from("hello");
    
    // 複数のイミュータブルな参照は可能
    let r1 = &s;
    let r2 = &s;
    println!("{} and {}", r1, r2);
    
    // ミュータブルな参照は1つだけ
    let r3 = &mut s;
    println!("{}", r3);
    
    // データ競合を防ぐ
    // let r4 = &s;     // エラー！イミュータブルとミュータブルは混在不可
    // let r5 = &mut s; // エラー！ミュータブルな参照は1つだけ
}
```

### スライス

```rust
fn main() {
    let s = String::from("hello world");
    
    let hello = &s[0..5];   // "hello"
    let world = &s[6..11];  // "world"
    let slice = &s[..];     // 全体
    
    let first_word = first_word(&s);
    println!("First word: {}", first_word);
    
    // 配列のスライス
    let a = [1, 2, 3, 4, 5];
    let slice = &a[1..3];   // [2, 3]
}

fn first_word(s: &String) -> &str {
    let bytes = s.as_bytes();
    
    for (i, &item) in bytes.iter().enumerate() {
        if item == b' ' {
            return &s[0..i];
        }
    }
    
    &s[..]
}
```

## 構造体とenum

### 構造体

```rust
struct User {
    username: String,
    email: String,
    sign_in_count: u64,
    active: bool,
}

struct Color(i32, i32, i32);  // タプル構造体
struct Point(i32, i32, i32);

struct UnitLikeStruct;  // ユニット様構造体

impl User {
    fn new(username: String, email: String) -> User {
        User {
            username,
            email,
            active: true,
            sign_in_count: 1,
        }
    }
    
    fn deactivate(&mut self) {
        self.active = false;
    }
    
    fn is_active(&self) -> bool {
        self.active
    }
}

fn main() {
    let mut user1 = User::new(
        String::from("someusername123"),
        String::from("someone@example.com"),
    );
    
    user1.email = String::from("anotheremail@example.com");
    user1.deactivate();
    
    println!("User active: {}", user1.is_active());
    
    let user2 = User {
        email: String::from("another@example.com"),
        username: String::from("anotherusername567"),
        ..user1  // 構造体更新記法
    };
}
```

### enum

```rust
enum IpAddrKind {
    V4,
    V6,
}

enum IpAddr {
    V4(u8, u8, u8, u8),
    V6(String),
}

enum Message {
    Quit,
    Move { x: i32, y: i32 },
    Write(String),
    ChangeColor(i32, i32, i32),
}

impl Message {
    fn call(&self) {
        match self {
            Message::Quit => println!("Quit"),
            Message::Move { x, y } => println!("Move to ({}, {})", x, y),
            Message::Write(text) => println!("Write: {}", text),
            Message::ChangeColor(r, g, b) => println!("Change color to ({}, {}, {})", r, g, b),
        }
    }
}

fn main() {
    let home = IpAddr::V4(127, 0, 0, 1);
    let loopback = IpAddr::V6(String::from("::1"));
    
    let m = Message::Write(String::from("hello"));
    m.call();
}
```

### Option enum

```rust
fn main() {
    let some_number = Some(5);
    let some_string = Some("a string");
    let absent_number: Option<i32> = None;
    
    let x: i8 = 5;
    let y: Option<i8> = Some(5);
    
    // let sum = x + y;  // エラー！i8とOption<i8>は異なる型
    
    match y {
        None => println!("No value"),
        Some(i) => println!("Value: {}", i),
    }
    
    // より簡潔な書き方
    if let Some(value) = y {
        println!("Got a value: {}", value);
    }
}
```

### パターンマッチング

```rust
fn main() {
    let dice_roll = 9;
    
    match dice_roll {
        3 => add_fancy_hat(),
        7 => remove_fancy_hat(),
        other => move_player(other),  // その他すべての値
    }
    
    // _ プレースホルダー
    match dice_roll {
        3 => add_fancy_hat(),
        7 => remove_fancy_hat(),
        _ => reroll(),  // その他は何もしない
    }
    
    // if let 式
    let some_u8_value = Some(0u8);
    if let Some(3) = some_u8_value {
        println!("three");
    } else {
        println!("not three");
    }
}

fn add_fancy_hat() {}
fn remove_fancy_hat() {}
fn move_player(num_spaces: u8) {}
fn reroll() {}
```

## エラーハンドリング

### Result型

```rust
use std::fs::File;
use std::io::ErrorKind;
use std::io::{self, Read};

fn main() {
    // パターンマッチングでエラーハンドリング
    let f = File::open("hello.txt");
    
    let f = match f {
        Ok(file) => file,
        Err(error) => match error.kind() {
            ErrorKind::NotFound => match File::create("hello.txt") {
                Ok(fc) => fc,
                Err(e) => panic!("Problem creating the file: {:?}", e),
            },
            other_error => panic!("Problem opening the file: {:?}", other_error),
        },
    };
    
    // unwrap()とexpect()
    let f = File::open("hello.txt").unwrap();
    let f = File::open("hello.txt").expect("Failed to open hello.txt");
    
    // ? 演算子
    let result = read_username_from_file();
    match result {
        Ok(username) => println!("Username: {}", username),
        Err(e) => println!("Error: {}", e),
    }
}

fn read_username_from_file() -> Result<String, io::Error> {
    let mut f = File::open("hello.txt")?;
    let mut s = String::new();
    f.read_to_string(&mut s)?;
    Ok(s)
}

// さらに簡潔な書き方
fn read_username_from_file_v2() -> Result<String, io::Error> {
    let mut s = String::new();
    File::open("hello.txt")?.read_to_string(&mut s)?;
    Ok(s)
}

// 最も簡潔な書き方
fn read_username_from_file_v3() -> Result<String, io::Error> {
    std::fs::read_to_string("hello.txt")
}
```

### カスタムエラー型

```rust
use std::fmt;

#[derive(Debug)]
enum MathError {
    DivisionByZero,
    NegativeLogarithm,
    NegativeSquareRoot,
}

impl fmt::Display for MathError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            MathError::DivisionByZero => write!(f, "Cannot divide by zero"),
            MathError::NegativeLogarithm => write!(f, "Cannot take logarithm of negative number"),
            MathError::NegativeSquareRoot => write!(f, "Cannot take square root of negative number"),
        }
    }
}

impl std::error::Error for MathError {}

fn divide(x: f64, y: f64) -> Result<f64, MathError> {
    if y == 0.0 {
        Err(MathError::DivisionByZero)
    } else {
        Ok(x / y)
    }
}

fn sqrt(x: f64) -> Result<f64, MathError> {
    if x < 0.0 {
        Err(MathError::NegativeSquareRoot)
    } else {
        Ok(x.sqrt())
    }
}

fn main() {
    match divide(10.0, 0.0) {
        Ok(result) => println!("Result: {}", result),
        Err(e) => println!("Error: {}", e),
    }
    
    match sqrt(-4.0) {
        Ok(result) => println!("Result: {}", result),
        Err(e) => println!("Error: {}", e),
    }
}
```

## ジェネリクスとトレイト

### ジェネリクス

```rust
fn largest<T: PartialOrd + Copy>(list: &[T]) -> T {
    let mut largest = list[0];
    
    for &item in list.iter() {
        if item > largest {
            largest = item;
        }
    }
    
    largest
}

struct Point<T> {
    x: T,
    y: T,
}

impl<T> Point<T> {
    fn new(x: T, y: T) -> Self {
        Point { x, y }
    }
    
    fn x(&self) -> &T {
        &self.x
    }
}

impl Point<f32> {
    fn distance_from_origin(&self) -> f32 {
        (self.x.powi(2) + self.y.powi(2)).sqrt()
    }
}

enum Option<T> {
    Some(T),
    None,
}

enum Result<T, E> {
    Ok(T),
    Err(E),
}

fn main() {
    let number_list = vec![34, 50, 25, 100, 65];
    let result = largest(&number_list);
    println!("The largest number is {}", result);
    
    let char_list = vec!['y', 'm', 'a', 'q'];
    let result = largest(&char_list);
    println!("The largest char is {}", result);
    
    let integer = Point::new(5, 10);
    let float = Point::new(1.0, 4.0);
}
```

### トレイト

```rust
trait Summary {
    fn summarize(&self) -> String;
    
    // デフォルト実装
    fn summarize_author(&self) -> String {
        String::from("(Read more...)")
    }
}

struct NewsArticle {
    headline: String,
    location: String,
    author: String,
    content: String,
}

impl Summary for NewsArticle {
    fn summarize(&self) -> String {
        format!("{}, by {} ({})", self.headline, self.author, self.location)
    }
}

struct Tweet {
    username: String,
    content: String,
    reply: bool,
    retweet: bool,
}

impl Summary for Tweet {
    fn summarize(&self) -> String {
        format!("{}: {}", self.username, self.content)
    }
    
    fn summarize_author(&self) -> String {
        format!("@{}", self.username)
    }
}

// トレイトを引数として受け取る
fn notify(item: &impl Summary) {
    println!("Breaking news! {}", item.summarize());
}

// トレイト境界構文
fn notify_v2<T: Summary>(item: &T) {
    println!("Breaking news! {}", item.summarize());
}

// 複数のトレイト境界
fn notify_v3<T: Summary + std::fmt::Display>(item: &T) {
    println!("Breaking news! {}", item.summarize());
}

// where句
fn some_function<T, U>(t: &T, u: &U) -> i32
    where T: std::fmt::Display + Clone,
          U: Clone + std::fmt::Debug
{
    // 実装
    0
}

// トレイトを返す
fn returns_summarizable() -> impl Summary {
    Tweet {
        username: String::from("horse_ebooks"),
        content: String::from("of course, as you probably already know, people"),
        reply: false,
        retweet: false,
    }
}

fn main() {
    let tweet = Tweet {
        username: String::from("horse_ebooks"),
        content: String::from("of course, as you probably already know, people"),
        reply: false,
        retweet: false,
    };
    
    println!("1 new tweet: {}", tweet.summarize());
    notify(&tweet);
}
```

### 派生可能なトレイト

```rust
#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord)]
struct Person {
    name: String,
    age: u32,
}

fn main() {
    let person1 = Person {
        name: String::from("Alice"),
        age: 30,
    };
    
    let person2 = person1.clone();
    
    println!("{:?}", person1);
    println!("Equal: {}", person1 == person2);
}
```

## ライフタイム

### ライフタイムの基本

```rust
fn main() {
    let r;
    
    {
        let x = 5;
        r = &x;  // エラー！xのライフタイムがrより短い
    }
    
    // println!("r: {}", r);  // エラー！
    
    // 正しい例
    let x = 5;
    let r = &x;
    println!("r: {}", r);
}
```

### ライフタイム注釈

```rust
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() {
        x
    } else {
        y
    }
}

fn main() {
    let string1 = String::from("abcd");
    let string2 = "xyz";
    
    let result = longest(string1.as_str(), string2);
    println!("The longest string is {}", result);
    
    // ライフタイムの関係
    let string1 = String::from("long string is long");
    {
        let string2 = String::from("xyz");
        let result = longest(string1.as_str(), string2.as_str());
        println!("The longest string is {}", result);
    }
}
```

### 構造体のライフタイム

```rust
struct ImportantExcerpt<'a> {
    part: &'a str,
}

impl<'a> ImportantExcerpt<'a> {
    fn level(&self) -> i32 {
        3
    }
    
    fn announce_and_return_part(&self, announcement: &str) -> &str {
        println!("Attention please: {}", announcement);
        self.part
    }
}

fn main() {
    let novel = String::from("Call me Ishmael. Some years ago...");
    let first_sentence = novel.split('.').next().expect("Could not find a '.'");
    let i = ImportantExcerpt {
        part: first_sentence,
    };
    
    println!("Important excerpt: {}", i.part);
}
```

### 静的ライフタイム

```rust
fn main() {
    let s: &'static str = "I have a static lifetime.";
    println!("{}", s);
}
```

## 並行性と非同期プログラミング

### スレッド

```rust
use std::thread;
use std::time::Duration;

fn main() {
    let handle = thread::spawn(|| {
        for i in 1..10 {
            println!("hi number {} from the spawned thread!", i);
            thread::sleep(Duration::from_millis(1));
        }
    });
    
    for i in 1..5 {
        println!("hi number {} from the main thread!", i);
        thread::sleep(Duration::from_millis(1));
    }
    
    handle.join().unwrap();
}
```

### ムーブクロージャ

```rust
use std::thread;

fn main() {
    let v = vec![1, 2, 3];
    
    let handle = thread::spawn(move || {
        println!("Here's a vector: {:?}", v);
    });
    
    handle.join().unwrap();
}
```

### チャネル

```rust
use std::sync::mpsc;
use std::thread;
use std::time::Duration;

fn main() {
    let (tx, rx) = mpsc::channel();
    
    thread::spawn(move || {
        let vals = vec![
            String::from("hi"),
            String::from("from"),
            String::from("the"),
            String::from("thread"),
        ];
        
        for val in vals {
            tx.send(val).unwrap();
            thread::sleep(Duration::from_secs(1));
        }
    });
    
    for received in rx {
        println!("Got: {}", received);
    }
}
```

### Mutex

```rust
use std::sync::{Arc, Mutex};
use std::thread;

fn main() {
    let counter = Arc::new(Mutex::new(0));
    let mut handles = vec![];
    
    for _ in 0..10 {
        let counter = Arc::clone(&counter);
        let handle = thread::spawn(move || {
            let mut num = counter.lock().unwrap();
            *num += 1;
        });
        handles.push(handle);
    }
    
    for handle in handles {
        handle.join().unwrap();
    }
    
    println!("Result: {}", *counter.lock().unwrap());
}
```

### 非同期プログラミング（Tokio）

```rust
// Cargo.tomlに追加:
// [dependencies]
// tokio = { version = "1", features = ["full"] }
// reqwest = { version = "0.11", features = ["json"] }

use tokio::time::{sleep, Duration};

#[tokio::main]
async fn main() {
    println!("Hello");
    
    let future1 = say_world();
    let future2 = count_to_5();
    
    // 並行実行
    tokio::join!(future1, future2);
}

async fn say_world() {
    sleep(Duration::from_millis(1000)).await;
    println!("World");
}

async fn count_to_5() {
    for i in 1..=5 {
        println!("Count: {}", i);
        sleep(Duration::from_millis(500)).await;
    }
}

// HTTP リクエストの例
async fn fetch_url(url: &str) -> Result<String, reqwest::Error> {
    let response = reqwest::get(url).await?;
    let body = response.text().await?;
    Ok(body)
}
```

## 実践プロジェクト

### CLIツールの作成

```rust
// Cargo.tomlに追加:
// [dependencies]
// clap = { version = "4.0", features = ["derive"] }

use clap::{Arg, Command};
use std::fs;
use std::io::{self, BufRead, BufReader};

fn main() {
    let matches = Command::new("word_count")
        .version("1.0")
        .about("Counts words, lines, and characters in a file")
        .arg(
            Arg::new("file")
                .help("The input file to use")
                .required(true)
                .index(1),
        )
        .arg(
            Arg::new("lines")
                .short('l')
                .long("lines")
                .help("Count lines")
                .action(clap::ArgAction::SetTrue),
        )
        .arg(
            Arg::new("words")
                .short('w')
                .long("words")
                .help("Count words")
                .action(clap::ArgAction::SetTrue),
        )
        .arg(
            Arg::new("chars")
                .short('c')
                .long("chars")
                .help("Count characters")
                .action(clap::ArgAction::SetTrue),
        )
        .get_matches();
    
    let filename = matches.get_one::<String>("file").unwrap();
    
    match count_file_stats(filename) {
        Ok((lines, words, chars)) => {
            if matches.get_flag("lines") {
                println!("Lines: {}", lines);
            }
            if matches.get_flag("words") {
                println!("Words: {}", words);
            }
            if matches.get_flag("chars") {
                println!("Characters: {}", chars);
            }
            if !matches.get_flag("lines") && !matches.get_flag("words") && !matches.get_flag("chars") {
                println!("Lines: {}, Words: {}, Characters: {}", lines, words, chars);
            }
        }
        Err(e) => eprintln!("Error reading file: {}", e),
    }
}

fn count_file_stats(filename: &str) -> io::Result<(usize, usize, usize)> {
    let file = fs::File::open(filename)?;
    let reader = BufReader::new(file);
    
    let mut lines = 0;
    let mut words = 0;
    let mut chars = 0;
    
    for line in reader.lines() {
        let line = line?;
        lines += 1;
        words += line.split_whitespace().count();
        chars += line.len() + 1; // +1 for newline character
    }
    
    Ok((lines, words, chars))
}
```

### Webサーバーの作成

```rust
// Cargo.tomlに追加:
// [dependencies]
// tokio = { version = "1", features = ["full"] }
// warp = "0.3"
// serde = { version = "1.0", features = ["derive"] }

use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::sync::{Arc, Mutex};
use warp::Filter;

type Users = Arc<Mutex<HashMap<u64, User>>>;

#[derive(Debug, Deserialize, Serialize, Clone)]
struct User {
    id: u64,
    name: String,
    email: String,
}

#[tokio::main]
async fn main() {
    let users: Users = Arc::new(Mutex::new(HashMap::new()));
    
    let users_filter = warp::any().map(move || users.clone());
    
    // GET /users
    let get_users = warp::path("users")
        .and(warp::get())
        .and(users_filter.clone())
        .and_then(get_users_handler);
    
    // POST /users
    let create_user = warp::path("users")
        .and(warp::post())
        .and(warp::body::json())
        .and(users_filter.clone())
        .and_then(create_user_handler);
    
    // GET /users/:id
    let get_user = warp::path!("users" / u64)
        .and(warp::get())
        .and(users_filter)
        .and_then(get_user_handler);
    
    let routes = get_users.or(create_user).or(get_user);
    
    warp::serve(routes)
        .run(([127, 0, 0, 1], 3030))
        .await;
}

async fn get_users_handler(users: Users) -> Result<impl warp::Reply, warp::Rejection> {
    let users = users.lock().unwrap();
    let users: Vec<User> = users.values().cloned().collect();
    Ok(warp::reply::json(&users))
}

async fn create_user_handler(user: User, users: Users) -> Result<impl warp::Reply, warp::Rejection> {
    let mut users = users.lock().unwrap();
    users.insert(user.id, user.clone());
    Ok(warp::reply::json(&user))
}

async fn get_user_handler(id: u64, users: Users) -> Result<impl warp::Reply, warp::Rejection> {
    let users = users.lock().unwrap();
    match users.get(&id) {
        Some(user) => Ok(warp::reply::json(user)),
        None => Err(warp::reject::not_found()),
    }
}
```

## パフォーマンス最適化

### ベンチマーク

```rust
// Cargo.tomlに追加:
// [dev-dependencies]
// criterion = "0.3"

use criterion::{black_box, criterion_group, criterion_main, Criterion};

fn fibonacci_recursive(n: u64) -> u64 {
    match n {
        0 => 1,
        1 => 1,
        n => fibonacci_recursive(n - 1) + fibonacci_recursive(n - 2),
    }
}

fn fibonacci_iterative(n: u64) -> u64 {
    let mut a = 0;
    let mut b = 1;
    
    for _ in 0..n {
        let tmp = a + b;
        a = b;
        b = tmp;
    }
    
    b
}

fn criterion_benchmark(c: &mut Criterion) {
    c.bench_function("fib recursive 20", |b| {
        b.iter(|| fibonacci_recursive(black_box(20)))
    });
    
    c.bench_function("fib iterative 20", |b| {
        b.iter(|| fibonacci_iterative(black_box(20)))
    });
}

criterion_group!(benches, criterion_benchmark);
criterion_main!(benches);
```

### メモリ効率

```rust
// 悪い例：不要なアロケーション
fn bad_string_processing(input: &str) -> String {
    let mut result = String::new();
    for line in input.lines() {
        let trimmed = line.trim().to_string(); // 不要なアロケーション
        if !trimmed.is_empty() {
            result.push_str(&trimmed);
            result.push('\n');
        }
    }
    result
}

// 良い例：アロケーションを避ける
fn good_string_processing(input: &str) -> String {
    let mut result = String::with_capacity(input.len()); // 容量を事前確保
    for line in input.lines() {
        let trimmed = line.trim(); // &str のまま
        if !trimmed.is_empty() {
            result.push_str(trimmed);
            result.push('\n');
        }
    }
    result
}

// Cow（Clone on Write）の使用
use std::borrow::Cow;

fn process_text(input: &str) -> Cow<str> {
    if input.contains("bad_word") {
        Cow::Owned(input.replace("bad_word", "***"))
    } else {
        Cow::Borrowed(input)
    }
}
```

### SIMD最適化

```rust
// Cargo.tomlに追加:
// [dependencies]
// rayon = "1.5"

use rayon::prelude::*;

fn sum_sequential(data: &[i32]) -> i32 {
    data.iter().sum()
}

fn sum_parallel(data: &[i32]) -> i32 {
    data.par_iter().sum()
}

fn main() {
    let data: Vec<i32> = (0..1_000_000).collect();
    
    let start = std::time::Instant::now();
    let result1 = sum_sequential(&data);
    let duration1 = start.elapsed();
    
    let start = std::time::Instant::now();
    let result2 = sum_parallel(&data);
    let duration2 = start.elapsed();
    
    println!("Sequential: {} in {:?}", result1, duration1);
    println!("Parallel: {} in {:?}", result2, duration2);
}
```

## エコシステムとベストプラクティス

### 重要なcrate

```toml
[dependencies]
# 非同期プログラミング
tokio = { version = "1", features = ["full"] }
async-std = "1.12"

# シリアライゼーション
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
toml = "0.5"

# エラーハンドリング
anyhow = "1.0"
thiserror = "1.0"

# ログ
log = "0.4"
env_logger = "0.9"
tracing = "0.1"

# HTTP クライアント/サーバー
reqwest = { version = "0.11", features = ["json"] }
warp = "0.3"
axum = "0.6"

# データベース
sqlx = { version = "0.6", features = ["runtime-tokio-rustls", "postgres"] }
diesel = { version = "2.0", features = ["postgres"] }

# CLI
clap = { version = "4.0", features = ["derive"] }
structopt = "0.3"

# 並列処理
rayon = "1.5"

# 日時
chrono = { version = "0.4", features = ["serde"] }

# UUID
uuid = { version = "1.0", features = ["v4", "serde"] }

# 正規表現
regex = "1.5"

# テスト
mockall = "0.11"
```

### プロジェクト構造

```
my_project/
├── Cargo.toml
├── Cargo.lock
├── README.md
├── src/
│   ├── main.rs
│   ├── lib.rs
│   ├── config.rs
│   ├── error.rs
│   ├── models/
│   │   ├── mod.rs
│   │   ├── user.rs
│   │   └── product.rs
│   ├── handlers/
│   │   ├── mod.rs
│   │   ├── user.rs
│   │   └── product.rs
│   └── utils/
│       ├── mod.rs
│       └── db.rs
├── tests/
│   ├── integration_test.rs
│   └── common/
│       └── mod.rs
├── benches/
│   └── benchmark.rs
└── examples/
    └── simple_example.rs
```

### テストのベストプラクティス

```rust
#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_add() {
        assert_eq!(add(2, 2), 4);
    }
    
    #[test]
    #[should_panic(expected = "divide by zero")]
    fn test_divide_by_zero() {
        divide(10, 0);
    }
    
    #[test]
    fn test_result() -> Result<(), String> {
        if 2 + 2 == 4 {
            Ok(())
        } else {
            Err(String::from("two plus two does not equal four"))
        }
    }
    
    // 統合テスト用のヘルパー関数
    fn setup() -> TestContext {
        TestContext::new()
    }
    
    #[tokio::test]
    async fn test_async_function() {
        let result = async_add(2, 2).await;
        assert_eq!(result, 4);
    }
}

// プロパティベーステスト
#[cfg(test)]
mod property_tests {
    use quickcheck_macros::quickcheck;
    
    #[quickcheck]
    fn reverse_twice_is_identity(xs: Vec<i32>) -> bool {
        let mut ys = xs.clone();
        ys.reverse();
        ys.reverse();
        xs == ys
    }
}
```

### エラーハンドリングのベストプラクティス

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum MyError {
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),
    
    #[error("Parse error: {0}")]
    Parse(#[from] std::num::ParseIntError),
    
    #[error("Custom error: {message}")]
    Custom { message: String },
    
    #[error("Network error")]
    Network,
}

// anyhowを使用した簡単なエラーハンドリング
use anyhow::{Context, Result};

fn read_config() -> Result<Config> {
    let contents = std::fs::read_to_string("config.toml")
        .context("Failed to read config file")?;
    
    let config: Config = toml::from_str(&contents)
        .context("Failed to parse config file")?;
    
    Ok(config)
}
```

### ログのベストプラクティス

```rust
use tracing::{info, warn, error, debug, instrument};

#[instrument]
async fn process_request(user_id: u64, request: String) -> Result<String, MyError> {
    debug!("Processing request for user {}", user_id);
    
    if request.is_empty() {
        warn!("Empty request received from user {}", user_id);
        return Err(MyError::Custom {
            message: "Empty request".to_string(),
        });
    }
    
    // 処理ロジック
    let result = do_complex_processing(&request).await?;
    
    info!("Successfully processed request for user {}", user_id);
    Ok(result)
}

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt::init();
    
    // アプリケーションの実行
}
```

## まとめ

このガイドでは、Rustの基礎から応用まで幅広くカバーしました。Rustをマスターするための重要なポイント：

### 学習のステップ
1. **基本文法の理解**：変数、関数、制御フロー
2. **所有権システムの習得**：Rustの核心概念
3. **構造体とenumの活用**：データモデリング
4. **エラーハンドリング**：堅牢なプログラムの作成
5. **ジェネリクスとトレイト**：抽象化と再利用性
6. **ライフタイム**：メモリ安全性の理解
7. **並行性**：パフォーマンスと安全性の両立

### 継続的な学習
- **公式ドキュメント**：[The Rust Programming Language](https://doc.rust-lang.org/book/)
- **Rust by Example**：[実践的な例](https://doc.rust-lang.org/rust-by-example/)
- **Rustlings**：[インタラクティブな練習問題](https://github.com/rust-lang/rustlings)
- **コミュニティ**：Reddit r/rust、Discord、フォーラム

### 実践的なアドバイス
1. **小さなプロジェクトから始める**
2. **コンパイラのエラーメッセージを読む習慣をつける**
3. **他の人のコードを読んで学ぶ**
4. **パフォーマンスよりも正確性を優先する**
5. **テストを書く習慣をつける**

Rustは学習曲線が急ですが、マスターすると非常にパワフルな言語です。継続的な練習と実践を通じて、安全で高速なシステムプログラミングができるようになります。

Happy Coding with Rust! 🦀