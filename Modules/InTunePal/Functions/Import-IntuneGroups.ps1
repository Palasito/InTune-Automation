function Import-IntuneGroups {

    [cmdletbinding()]

    param(
        [Parameter(mandatory)]
        $Path,
        [switch]$Token,
        [switch]$Named,
        [switch]$Conditional,
        [switch]$Compliance,
        [switch]$Configuration,
        [switch]$Update,
        [switch]$CApps,
        [switch]$ApplicationProt,
        [switch]$EndpointSec
    )
}