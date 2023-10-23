# Scripts

Scripts for COMP 311 (Computer Organization) at UNC.

## install.sh

Bash script (i.e., macOS/Linux, not Windows) that downloads [Digital](https://github.com/hneemann/Digital), [SAPsim](https://github.com/jesse-wei/SAPsim), and [MARS](http://courses.missouristate.edu/kenvollmar/mars/). The script also aliases commands for launching the programs.

```bash
curl -s "https://raw.githubusercontent.com/COMP311/scripts/main/install.sh" | bash
```

After restarting the terminal,

* Run `digital` to launch `Digital.jar`
* Run `mars` to launch `Mars4_5.jar`
* For Digital, run `digital file.dig` to directly open `file.dig` on launch. However, this does not work for MARS.
* SAPsim was installed via pip. See https://github.com/jesse-wei/sapsim#usage for usage details.

### Credits

* [Digital](https://github.com/hneemann/Digital)
    * [Helmut Neemann](https://github.com/hneemann)
* [SAPsim](https://github.com/jesse-wei/SAPsim)
    * [Jesse Wei](https://jessewei.dev)
* [MARS](http://courses.missouristate.edu/kenvollmar/mars/)
    * [Kenneth Vollmar](https://courses.missouristate.edu/KenVollmar/)
    * [Pete Sanderson](http://faculty.otterbein.edu/PSanderson/)
