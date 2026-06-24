{
  description = "wgpu dev-environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      # Выносим системные зависимости (Wayland, X11, Vulkan) в отдельный список
      wayland_x11_libs = with pkgs; [
        wayland
        vulkan-loader
        libxkbcommon # Обязательно для обработки ввода с клавиатуры в Wayland

        # Фолбэки для X11 (winit использует их, если Wayland недоступен)
        xorg.libX11
        xorg.libXcursor
        xorg.libXrandr
        xorg.libXi
      ];
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs =
          with pkgs;
          [
            cargo
            rustc
            rustfmt
            rust-analyzer
            python311
            pkg-config
            openssl
          ]
          ++ wayland_x11_libs;

        RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";

        # Та самая магия NixOS: склеиваем пути к библиотекам и кладем в переменную
        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath wayland_x11_libs;
      };
    };
}
