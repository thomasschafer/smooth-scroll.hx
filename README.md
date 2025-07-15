# smooth-scroll.hx

`smooth-scroll.hx` is a plugin for [Helix](https://github.com/helix-editor/helix/) which provides built-in function replacements which scroll smoothly between positions. The full list of functions can be seen in the installation section.

https://github.com/user-attachments/assets/2cf59e34-f6db-4f1e-9254-ea0298ae5cfd

## Installation

Follow the instructions [here](https://github.com/mattwparas/helix/blob/steel-event-system/STEEL.md) to install Helix on the plugin branch.

Then, install the plugin with:

```sh
forge pkg install --git https://github.com/thomasschafer/smooth-scroll.hx.git
```

Once installed, you can add the following to `init.scm` in your Helix config directory:

```scheme
(require "smooth-scroll/smooth-scroll.scm")
```

Then, you can update your `config.toml` to make use of the smooth scrolling functions:

```toml
[keys.normal]
C-d = ":half-page-down-smooth"
C-u = ":half-page-up-smooth"
pageup = ":page-up-smooth"
pagedown = ":page-down-smooth"
```
