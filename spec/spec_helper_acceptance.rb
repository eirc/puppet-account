require 'beaker-rspec'
require 'pry'

unless ENV['BEAKER_provision'] == 'no'
  hosts.each do |host|
    install_package host, 'rubygems'
    on host, 'gem install puppet --no-ri --no-rdoc'
    on host, "mkdir -p #{host['distmoduledir']}"
  end
end

RSpec.configure do |c|
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  c.formatter = :documentation
  c.before :suite do
    puppet_module_install(:source => proj_root, :module_name => 'account')
  end
end

def apply_manifest(host, manifest)
  # Run it twice and test for idempotency
  apply_manifest_on(host, manifest, :catch_failures => true)
  apply_manifest_on(host, manifest, :catch_failures => true).exit_code.should be_zero
end

RSA_PRIVATE_KEY = <<-KEY.strip
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAwzYS9IyJNUlPQT1ZnsgoOqk4zwGJ8N/IMODRkYIDazdqrQs2
Sru2Cc0YQqH/2LWoKx7qVJp2KpObzUNb3fxh8VgxDpidGYmpZQf2PAcmlqVVeMD3
qKVo0qWpL4Vk27pgQ+J8VSPY090gvabMtChmu+4jFULlOfU6gwwIy61vHyq0LSFU
QjOhh3sTLwzFLNWrNx5hqUrRD1a/LVujlXTJzN6PhTWdlfnw/a4bripx9ha8Tzii
9gsf6LCUksmyXg/JjnJjCwMIe2PrJxDZ7FDxBRsW8QiH13SpNFxZ+RusNjTaFJ99
9FHnEoilzZ4OG/v44q1rkpkKRCOJU2TGOINDqwIDAQABAoIBAQCbiSUXNjZIf62n
JHOYoI/1FUmPHgHDKvo9f5NapUWGErRrRcivSNqk+oW+6YaJK0vfd5VrbVqDV/LG
XEoBGAsNmaAUqiJZ66ZNOkfF0ki7tOXh/ZYWCBz54UZo95bBv8DdtcIssBAd1k00
7oahcKNST04irZcoU6yYJ2mGpxwnrqAllCDbEp0czE9zfWmTPNc1chMJm8cfFM6C
rCqQTmn/mJXEH4OQe/QpOR4JaVjpjdfswIvcupWgy2St5Y019TUIDX3RzIiJX3yq
MIqOyPYjTGhw+Ao/ZgbsNjwBm5qIVc7nD8WuWINpXIk7+Ud+3vb9WkoUbv2aR+mO
isTFdwQJAoGBAPPcvhn6RCFkYs/fY0tROlbJ/E8zIHQJpL++/LiDRr4hqk4fJE7k
gs7tmp8CgMwgfX76pt5TfuURQ31/62c7iiOm6KAJBWGWl9FO90dywy4QXV0lvyPT
mOutEQh4UzuG3NrjxrIlDkd4J6HEpUAatr1Z85dWaD2U5GVEnPIx+n63AoGBAMzt
bUplGVLojjG2NfNNY7tevNSn5MWj0JyaEIJv4PmVPM8Kqq6zgdjWIDVAZDrjnwv8
y6e7kErYwS/z/FEMwJylo7T/5An8ZLli//ZOI3ae+NfBzXsZbvWgwzX4gb5lib4W
7uc+fSgoAYyPhtEItxs5ajVaOUVmf8NXcNClf26tAoGBAJiu6BOJv2iM2tU+D4RT
ukwmsSPBZhthAlbPtJmuD/fxShkZpHkE1+XJnJrcTVoBKbH8K8hdzMCNW41TL0d2
XtpNoa65lzXvvORfJbIFZ7EKq/orLQ64aDF/LX/5HlvR56vhG0Hks5kJ4P6HCdQm
Ja5OiJaDkkakV5AUMpPtuOHnAoGAHk5Oh14ELLqvrLJhsCWVxjPwgRKDRqc/RqmS
H3gkMUTcxVGyhDuPzF1+TeHD8OGQt9ke1SNr52W+zDSs79+O7JuiZjYhp0hoLPJz
IB3WKMjBzEag+L9+JV0tAWJK7blecXo6wn//Sl0APaVMLsW3LpODHXjGV3kdE+pu
iKyw99ECgYA4iT4okqZQwtQFDoZN6r0IWPV4/PsWFLvUajkIqb0WOCFSVGIpBYsI
pqiCJ0k/PAcGVer6PQmNPf9JZBW0YMheazUYRfve0yAUp+UGuH1v72Ua0oDYW4Kz
JJX0KzPGf9qEiNcl209QYZwDxKHWUjVODUqR3R2NbOU1QFsP4h2z4w==
-----END RSA PRIVATE KEY-----
KEY

RSA_PUBLIC_KEY = <<-KEY.strip
AAAAB3NzaC1yc2EAAAADAQABAAABAQDDNhL0jIk1SU9BPVmeyCg6qTjPAYnw38gw4NGRggNrN2qtCzZKu7YJzRhCof/YtagrHupUmnYqk5vNQ1vd/GHxWDEOmJ0ZiallB/Y8ByaWpVV4wPeopWjSpakvhWTbumBD4nxVI9jT3SC9psy0KGa77iMVQuU59TqDDAjLrW8fKrQtIVRCM6GHexMvDMUs1as3HmGpStEPVr8tW6OVdMnM3o+FNZ2V+fD9rhuuKnH2FrxPOKL2Cx/osJSSybJeD8mOcmMLAwh7Y+snENnsUPEFGxbxCIfXdKk0XFn5G6w2NNoUn330UecSiKXNng4b+/jirWuSmQpEI4lTZMY4g0Or
KEY
