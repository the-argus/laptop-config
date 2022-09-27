{
  override,
  basekernelsuffix,
  ...
}: (self: super: let
  dirVersionNames = {
    xanmod_latest = "xanmod";
    "5_15" = "";
    "5_19" = "";
  };
  dirVersionName =
    if builtins.hasAttr basekernelsuffix dirVersionNames
    then
      (
        if dirVersionNames.${basekernelsuffix} == ""
        then ""
        else "-${dirVersionNames.${basekernelsuffix}}1"
      )
    else basekernelsuffix;
  basekernel = "linux${
    if basekernelsuffix == ""
    then ""
    else "_"
  }${basekernelsuffix}";
  src = super.linuxKernel.kernels.${basekernel}.src;
  version = super.linuxKernel.kernels.${basekernel}.version;
  override = nixpkgs.lib.attrsets.recursiveUpdate;
in {
  linuxKernel = override super.linuxKernel {
    kernels = {
      linux_xanmod_latest =
        (super.linuxKernel.manualConfig {
          stdenv = super.gccStdenv;
          inherit src version;
          modDirVersion = "${version}${dirVersionName}-${super.lib.strings.toUpper hostname}";
          inherit (super) lib;
          configfile = super.callPackage ./kernelconfig.nix {
            inherit hostname;
          };
          allowImportFromDerivation = true;
        })
        .overrideAttrs (oa: {
          nativeBuildInputs = (oa.nativeBuildInputs or []) ++ [super.lz4];
          # originally "xhci_pci thunderbolt nvme usb_storage sd_mod md_mod raid0 raid1 raid10 raid456 ext2 ext4 ahci sata_nv sata_via sata_sis sata_uli ata_piix pata_marvell sd_mod sr_mod mmc_block uhci_hcd ehci_hcd ehci_pci ohci_hcd ohci_pci xhci_hcd xhci_pci usbhid hid_generic hid_lenovo hid_apple hid_roccat hid_logitech_hidpp hid_logitech_dj hid_microsoft hid_cherry pcips2 atkbd i8042 rtc_cmos dm_mod"
        });
    };
  };
})
