{ lib, fetchpatch, fetchurl }:

{
  ath_regd_optional = rec {
    name = "ath_regd_optional";
    patch = fetchpatch {
      name = name + ".patch";
      url = "https://github.com/openwrt/openwrt/raw/ed2015c38617ed6624471e77f27fbb0c58c8c660/package/kernel/mac80211/patches/ath/402-ath_regd_optional.patch";
      sha256 = "1ssDXSweHhF+pMZyd6kSrzeW60eb6MO6tlf0il17RC0=";
      postFetch = ''
        sed -i 's/CPTCFG_/CONFIG_/g' $out
        sed -i '/--- a\/local-symbols/,$d' $out
      '';
    };
  };

  bridge_stp_helper =
    { name = "bridge-stp-helper";
      patch = ./bridge-stp-helper.patch;
    };

  request_key_helper =
    { name = "request-key-helper";
      patch = ./request-key-helper.patch;
    };

  request_key_helper_updated =
    { name = "request-key-helper-updated";
      patch = ./request-key-helper-updated.patch;
    };

  modinst_arg_list_too_long =
    { name = "modinst-arglist-too-long";
      patch = ./modinst-arg-list-too-long.patch;
    };

  cpu-cgroup-v2 = import ./cpu-cgroup-v2-patches;

  hardened = let
    mkPatch = kernelVersion: { version, sha256, patch }: let src = patch; in {
      name = lib.removeSuffix ".patch" src.name;
      patch = fetchurl (lib.filterAttrs (k: v: k != "extra") src);
      extra = src.extra;
      inherit version sha256;
    };
    patches = lib.importJSON ./hardened/patches.json;
  in lib.mapAttrs mkPatch patches;

  # Adapted for Linux 5.4 from:
  # https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=04896832c94aae4842100cafb8d3a73e1bed3a45
  rtl8761b_support =
    { name = "rtl8761b-support";
      patch = ./rtl8761b-support.patch;
    };

  export-rt-sched-migrate = {
    name = "export-rt-sched-migrate";
    patch = ./export-rt-sched-migrate.patch;
  };

  fix-em-ice-bonding = {
    name = "fix-em-ice-bonding";
    patch = ./fix-em-ice-bonding.patch;
  };

  # https://lore.kernel.org/linux-wireless/ZAx0TWRBlGfv7pNl@kroah.com/T/#m11e6e0915ab8fa19ce8bc9695ab288c0fe018edf
  fix-brcmfmac = {
    name = "fix-brcmfmac";
    patch = fetchpatch {
      url = "https://lore.kernel.org/linux-wireless/20230311141914.24444-1-marcan@marcan.st/raw";
      sha256 = "sha256-Fjap48Lef8Mi1i0t13/rT2SoYcbO8HJuXhJMn7HK3Ds=";
    };
  };
}
