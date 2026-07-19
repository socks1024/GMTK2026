---
name: gdshader-coding-guideline
description: GDShader 编码规范。在编写或修改 GDShader 代码时使用此 skill。
---

# GDShader 编码规范

## 入口函数

- **禁止 `return;`**（无值的提前返回），用条件分支代替
- `fragment()`、`vertex()`、`light()` 等入口函数返回类型为 void，不能使用 `return <值>`

✅ 正确（用条件分支）：
```glsl
void fragment() {
    if (some_condition) {
        COLOR = texture(TEXTURE, UV);
    } else {
        COLOR = vec4(0.0);
    }
}
```

❌ 错误：
```glsl
void fragment() {
    return texture(TEXTURE, UV); // 编译错误：void 函数不能返回值
}
```
```glsl
void fragment() {
    if (!enabled) {
        return; // 禁止提前返回
    }
    COLOR = texture(TEXTURE, UV);
}
```

## 自定义函数

自定义的有返回值的函数可以正常使用 `return`：
```glsl
float my_func(float x) {
    return x * 2.0;
}