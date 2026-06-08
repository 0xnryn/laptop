let

  root = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJQgPPuvnBiaK6z3ADBqY5l11oB6HHwm1rtUAEusMSlx root";
  
  /*userssh*/ sudhassh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAPOVwS487rUg6zfTKdeRILuaF2MAkj+0Hb+VybiY/MK sudha";  
  /*hostssh*/ sudhalaptopssh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDOJRuZDBhEn9Q37C0qZ8jMo6EMrTe7bzTT4hKcBMBN9 sudhalaptop";
  /*hosttpm*/ sudhalaptoptpm = "age1tag1qv37tamvtdydm3m3zg9g6k8st3m5nvggacy2h6wkha44sqgl944cyw3mek9";

in
{
  "modules/machines/laptop/secrets/sudhalaptopssh.age".publicKeys  = [ root ] ++ [ sudhalaptoptpm ];
  "modules/users/sudha/secrets/sudhassh.age".publicKeys = [ root ] ++ [ sudhalaptopssh sudhalaptoptpm ];
  "modules/users/sudha/secrets/sudhauserpass.age".publicKeys = [ root ] ++ [ sudhassh sudhalaptoptpm ];
}