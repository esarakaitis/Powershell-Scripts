get-vm | foreach-object `
{$_ | `
select @{name="Hostname"; expression={$_.name}}, @{name="Processors"; expression={$_.numcpu}}, @{name="Memory Allocated"; expression={$_.memorymb}}, @{name="Host"; expression={$_.host}}}