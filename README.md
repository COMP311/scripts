# Scripts

Scripts for COMP 311 (Computer Organization) at UNC.

## install.sh

Bash script that downloads all software required for COMP 311 ([Digital](https://github.com/hneemann/Digital), [SAPsim](https://github.com/jesse-wei/SAPsim), and [MARS](http://courses.missouristate.edu/kenvollmar/mars/)) and creates aliases for launching the programs.

```bash
curl -s "https://raw.githubusercontent.com/COMP311/scripts/main/install.sh" | bash
```

Follow the instructions in the printed output about how to run the JAR files via an alias. Doing so will block your terminal. If you don't want to open additional sessions while running a JAR file from the terminal, use [tmux](https://www.hamvocke.com/blog/a-quick-and-easy-guide-to-tmux/).

### Credits

* [Digital](https://github.com/hneemann/Digital)
    * [Helmut Neemann](https://github.com/hneemann)
* [SAPsim](https://github.com/jesse-wei/SAPsim)
    * [Jesse Wei](https://jessewei.dev)
* [MARS](http://courses.missouristate.edu/kenvollmar/mars/)
    * [Kenneth Vollmar](https://courses.missouristate.edu/KenVollmar/)
    * [Pete Sanderson](http://faculty.otterbein.edu/PSanderson/)
