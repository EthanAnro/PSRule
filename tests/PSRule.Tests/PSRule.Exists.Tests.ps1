#
# Unit tests for the Exists keyword
#

[CmdletBinding()]
param (

)

# Setup error handling
$ErrorActionPreference = 'Stop';
Set-StrictMode -Version latest;

# Setup tests paths
$rootPath = $PWD;

Import-Module (Join-Path -Path $rootPath -ChildPath out/modules/PSRule) -Force;
$here = (Resolve-Path $PSScriptRoot).Path;

Describe 'PSRule -- Exists keyword' -Tag 'Exists' {
    $ruleFilePath = (Join-Path -Path $here -ChildPath 'FromFile.Rule.ps1');

    Context 'Exists' {
        It 'With defaults' {
            $testObject = [PSCustomObject]@{
                Name = 'TestObject1'
                Value = @{
                    Value1 = 1
                }
                Properties = $Null
            }
            $result = $testObject | Invoke-PSRule -Path $ruleFilePath -Tag @{ keyword = 'Exists' };

            # Test positive cases
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'ExistsTest' };
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.IsSuccess() | Should -Be $True;
            $filteredResult.Reason | Should -BeNullOrEmpty;

            # Test negative cases
            $filteredResult = $result | Where-Object { $_.RuleName -eq 'ExistsTestNegative' };
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.IsSuccess() | Should -Be $False;
            $filteredResult.Reason | Should -BeLike "None of the field(s) existed: *";
        }

        It 'If pre-condition' {
            $testObject = @(
                [PSCustomObject]@{
                    Name = 'TestObject1'
                }
                [PSCustomObject]@{
                    NotName = 'TestObject2'
                }
            )
            $option = New-PSRuleOption -NotProcessedWarning $False
            $result = $testObject | Invoke-PSRule -Path $ruleFilePath -Name 'ExistsCondition' -Outcome All -Option $option;

            # Test positive cases
            $filteredResult = $result | Where-Object { $_.TargetName -eq 'TestObject1' };
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Outcome | Should -Be 'Pass';

            # Test negative cases
            $filteredResult = $result | Where-Object { $_.TargetName -ne 'TestObject1' };
            $filteredResult | Should -Not -BeNullOrEmpty;
            $filteredResult.Outcome | Should -Be 'None';
        }
    }
}
