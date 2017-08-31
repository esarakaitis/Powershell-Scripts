get-vmhost | foreach-object `
{$vmhost=$_
(set-baseline "blue")}