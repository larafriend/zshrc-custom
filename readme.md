# 🛠 Zsh + Oh My Zsh + Powerlevel10k Setup Script

This script provides an interactive, step-by-step setup for installing and configuring:

- **Zsh** (shell)
- **Oh My Zsh** (Zsh configuration framework)
- **Powerlevel10k** (highly customizable Zsh theme)
- Your own **custom configuration** (`custom/` and `custom.zshrc`)
- Optional installation of the **Meslo LGS NF Nerd Font** (required for proper Powerlevel10k display)

---

## 🚀 Features

- Fully **interactive** with Y/N prompts
- **Modular structure** for easy editing and maintenance
- Automatically installs dependencies and configures your `.zshrc`
- Backs up your existing `.zshrc`
- Guides you step-by-step with clear output

---

## 📦 Requirements

- macOS or Linux
- `bash`, `curl`, `git`
- Optional:
	- `brew` for macOS
	- `apt` for Debian/Ubuntu

---

## 🧑‍💻 How to Use

1. Clone or download this repository:

```bash
git clone https://github.com/yourusername/zsh-setup.git
cd zsh-setup
```

2. Make the script executable:

```bash
chmod +x setup.sh
```

3. Run the script:

```bash
./setup.sh
```

> Follow the prompts. You’ll be asked to install Zsh, Oh My Zsh, apply your custom files, and configure Powerlevel10k.

## 📝 Customization

You can customize the script by editing the `custom/` directory and `custom.zshrc` file. This allows you to add your own
aliases, functions, and configurations that will be applied after the main setup.

`custom/ Folder`
Add your own plugins, themes, or overrides inside the custom/ directory. It will be copied to ~/.oh-my-zsh/custom/.

`custom.zshrc`
This file is sourced at the end of the setup process. You can add any additional configurations or commands you want to
run after the main setup.

## 🔤 Font Recommendation

If you enable Powerlevel10k, it’s strongly recommended to install the MesloLGS NF Nerd Font for icons and layout to
display correctly.

The script will offer to install it for you.

## 🛠️ Troubleshooting

If you encounter issues, check the following:

- Ensure you have the required dependencies installed (`bash`, `curl`, `git`).
- Make sure you have the necessary permissions to install software.
- Check the script output for any error messages and follow the instructions provided.
- If you have an existing `.zshrc`, the script will back it up to `~/.zshrc.backup` before applying changes.
- If you run into issues with Powerlevel10k, try reconfiguring it by running `p10k configure` in your terminal.
- If you have issues with fonts, ensure that the MesloLGS NF Nerd Font is installed correctly and set as your terminal's
  font.
- If you have issues with Oh My Zsh, you can try reinstalling it by running `omz update` or `omz self-update`.
- If you have issues with plugins, ensure they are correctly installed in the `~/.oh-my-zsh/custom/plugins/` directory.
- If you have issues with themes, ensure they are correctly installed in the `~/.oh-my-zsh/custom/themes/` directory.
- If you have issues with custom configurations, ensure they are correctly placed in the `custom/` directory and sourced
  in `custom.zshrc`.
- If you have issues with the script itself, feel free to open an issue on the GitHub repository.

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 📞 Support

If you have any questions or need support, feel free to open an issue on the GitHub repository.

## 📢 Contributing

Contributions are welcome! If you have suggestions or improvements, please open a pull request or issue on the GitHub
repository.

## 📚 Acknowledgements

This script is inspired by various Zsh setup guides and the amazing work of the Oh My Zsh and Powerlevel10k communities.

## 📖 Documentation

For more information on Zsh, Oh My Zsh, and Powerlevel10k, check out their official documentation:

- [Zsh Documentation](https://www.zsh.org/documentation/)
- [Oh My Zsh Documentation](https://ohmyz.sh/)
- [Powerlevel10k Documentation](https://github.com/romkatv/powerlevel10k)
- [Nerd Fonts Documentation](https://www.nerdfonts.com/)
- [MesloLGS NF Nerd Font](https://github.com/romkatv/dotfiles-public/tree/master/.local/share/fonts/NerdFonts)
- [Zsh Customization Guide](https://zsh.sourceforge.io/Intro/intro_3.html)
- [Zsh Plugins](https://github.com/ohmyzsh/ohmyzsh/wiki/plugins)
- [Zsh Themes](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes)

## 🏷️ Tags

#zsh #ohmyzsh #powerlevel10k #setup #script #customization #zshconfig #terminal #linux #macos #bash #nerdfonts
