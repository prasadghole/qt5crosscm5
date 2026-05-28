# RemoteQtApp: Cross-compile for Raspberry Pi CM5 and debug from Qt Creator

This project builds a Qt 5 Widgets application for a Raspberry Pi Compute Module 5
(`aarch64`) from an x86_64 host. The expected workflow is:

1. Build an ARM64 **Debug** binary on the host.
2. Deploy the binary to the CM5 over SSH.
3. Start `gdbserver` on the CM5.
4. Attach Qt Creator on the host to `gdbserver` using an ARM64-capable GDB.

## Target CM5 prerequisites

Install the runtime libraries and debugger server on the CM5:

```bash
sudo apt update
sudo apt install -y gdbserver libqt5widgets5 libqt5gui5 libqt5core5a
```

For GUI applications, make sure you launch under the display session that owns the
screen. For a local desktop session, `DISPLAY=:0` is typically enough; Wayland
setups may also require `XDG_RUNTIME_DIR=/run/user/1000`.

## Host prerequisites

Install Qt Creator and an ARM64-capable debugger on the host:

```bash
sudo apt install -y qtcreator gdb-multiarch openssh-client rsync
```

If you build locally instead of with Docker, also install the ARM64 cross compiler
and ARM64 Qt development packages that match `pi_toolchain.cmake`.

## Build a debug ARM64 binary

The default cross build type is `Debug`, which keeps symbols available for Qt
Creator source-level debugging:

```bash
make pi
```

To choose another CMake build type:

```bash
make pi BUILD_TYPE=RelWithDebInfo
```

The ARM64 binary is created at:

```text
build_pi/RemoteQtApp
```

You can verify the architecture before deployment:

```bash
file build_pi/RemoteQtApp
```

## Deploy to the CM5

Set the SSH destination and copy the application to the target:

```bash
make deploy-pi REMOTE_USER=pi REMOTE_HOST=cm5.local
```

Optional variables:

- `REMOTE_DIR=/home/pi/RemoteQtApp` changes the target directory.
- `TARGET=RemoteQtApp` changes the executable name if the CMake target changes.

## Start a remote debug session

Start `gdbserver` on the CM5 from the host:

```bash
make debug-pi REMOTE_USER=pi REMOTE_HOST=cm5.local
```

By default this listens on TCP port `2345`. Override with `REMOTE_PORT=1234` if
needed. The make target exports `DISPLAY` and `XDG_RUNTIME_DIR` before launching
the application so a Qt Widgets GUI can appear on the CM5 display.

## Qt Creator configuration

Configure Qt Creator on the host as follows:

1. **Device**: `Preferences` / `Options` > `Devices` > `Devices` > `Add` >
   `Generic Linux Device`. Enter the CM5 SSH host, user, and authentication.
2. **Compiler**: `Preferences` / `Options` > `Kits` > `Compilers` > `Add` >
   `GCC` > `C++`, then select `aarch64-linux-gnu-g++`.
3. **Debugger**: `Preferences` / `Options` > `Kits` > `Debuggers` > `Add`, then
   select `gdb-multiarch` or another GDB configured for `aarch64`.
4. **CMake toolchain**: open this project and configure CMake with:

   ```text
   -DCMAKE_TOOLCHAIN_FILE=%{sourceDir}/pi_toolchain.cmake
   -DCMAKE_BUILD_TYPE=Debug
   ```

5. **Kit**: create a kit that combines the ARM64 compiler, ARM64 debugger,
   CMake, and the CM5 remote Linux device.
6. **Run settings**: set the local executable to `build_pi/RemoteQtApp` and the
   remote executable to the path used by deployment, for example
   `/home/pi/RemoteQtApp/RemoteQtApp`.
7. **Debugger attach**: after running `make debug-pi`, use Qt Creator's
   `Debug > Start Debugging > Attach to Running Debug Server` and connect to
   `cm5.local:2345`. Select the local executable with symbols:
   `build_pi/RemoteQtApp`.

## Troubleshooting

- If Qt Creator cannot resolve source lines, rebuild with `make pi BUILD_TYPE=Debug`.
- If breakpoints stay pending, confirm Qt Creator is using the local
  `build_pi/RemoteQtApp` file, not only the stripped remote copy.
- If the application fails to start remotely with display errors, SSH into the
  CM5 desktop user and check `echo $DISPLAY` and `echo $XDG_RUNTIME_DIR`.
- If deployment succeeds but `gdbserver` is missing, install it on the CM5 with
  `sudo apt install gdbserver`.
