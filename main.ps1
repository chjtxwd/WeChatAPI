$a = curl "https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=&"
$b= $a.content | ConvertFrom-Json
$access_token = $b.access_token
$c = curl "https://qyapi.weixin.qq.com/cgi-bin/department/list?access_token=$access_token&"
$d = $c.content | ConvertFrom-Json
$departments = $d.department
$stores = $departments | Where-Object -FilterScript {$_.name -match "^[1-9]\d*"}
$result =$null
rm .\information.csv

foreach($store in $stores){
$department_id = $store.id
$storename = $store.name
$onestore = curl "https://qyapi.weixin.qq.com/cgi-bin/user/list?access_token=$access_token&department_id=$department_id&fetch_child=1"
$onestoreJson = $onestore.Content | ConvertFrom-Json
$userlist = $onestoreJson.userlist
$userlist|Add-Member store "$storename"
$userlist|Add-Member storeName "$storename"
$userlist|Add-Member storeNumber "$storename"

$tempResult = $userlist | Where-Object -FilterScript {$_.position -eq ”店长“ -or $_.position -eq ”营运经理“}

foreach($tempuser in $tempResult){


if($tempuser.position -eq ”店长“){ $tempuser.position = "store manager"}

if($tempuser.position -eq ”营运经理“){ $tempuser.position = "op"}

$y=$tempuser.store.Split()[0]
$z=$tempuser.store.Split()[1]
$tempuser.storeNumber = $y
$tempuser.storeName = $z


}
$result = $result + $tempResult

}
$result |Select-Object storeNumber ,storeName,name,position,mobile,email,alias  |Export-Csv   .\information.csv -Encoding UTF8 -NoTypeInformation 
$a = Get-Date
echo "$a" >> .\\information.csv
