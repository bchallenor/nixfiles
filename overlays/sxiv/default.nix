self: super: {
  sxiv = super.sxiv.overrideAttrs(attrs: {
    patches = [
      ./hidpi.patch
    ];
  });
}
