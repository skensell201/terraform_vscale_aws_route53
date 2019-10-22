# Creating two records in Route53 with help Terraform

Описание как создать записи Amazon Route53 с помощью Terraform

## Requirements:

* [Terraform](https://www.terraform.io/downloads.html)
* Установить [awscli](https://aws.amazon.com/ru/cli/)
* Установить [GO](https://golang.org/doc/install) для сборки плагина
* Плагин с провайдером [Vscale](https://github.com/burkostya/terraform-provider-vscale) для создания виртуальных машин



### First steps
* Необходимо настроить переменные окружения GO

```
$ export PATH=$PATH:$(go env GOPATH)/bin
$ export GOPATH=$(go env GOPATH)
```

* Клонируем репозиторий в директорию terraform-providers
```
$ mkdir -p $GOPATH/src/github.com/terraform-providers
$ cd $GOPATH/src/github.com/terraform-providers
$ git clone git@github.com:burkostya/terraform-provider-vscale.git
```

### Compile and install plugin

В директории terraform-provider-vscale запускаем go build (может оказаться что не будет хватать зависимостей нужно будет собрать их самим )

```
$ go build
// Если не будет хватать зависимостей, получить их с помощью этой команды и заново запустить go build
$ go get github.com/dependence_example
```

После компиляция появится файл terraform-provider-vscale его нужно перенести в директорию ~/.terraform.d/plugins

```
$ mv terraform-provider-vscale ~/.terraform.d/plugins
```

Что бы проверить что все прошло успешно создаем новую директорию с .tf файлом

```
$ mkdir testvscale && cd testvscale
$ touch main.tf
```
В файл main.tf вносим следующие изменения и сохраняем

```
provider "vscale" {
  token = "%VSCALE_TOKEN%"
}
```
Запускаем terraform init
```
$ terraform init
```
Вывод должен быть как ниже, если он соответсвует значит все прошло успешно и вы можете использовать провайдер Vscale
```
Initializing the backend...

Initializing provider plugins...

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

* После установки всего необходимого нужно настроить **awscli**, это понадобится для обращения к API Amazon Cloud

```
$ aws configure
AWS Access Key ID [None]: your_access_key
AWS Secret Access Key [None]: your_secret_key
Default region name [None]: default_region (можно не указывать)
Default output format [None]: json (формат в котором будет выводится информация при запросах к API Amazon)
```
* Проект будет содержать файлы:
1. **main.tf** - В этом файле описываются провайдеры и создаваемые ресурсы
2. **variables.tf** - Описывает перменные и их описание
3. **outputs.tf** - Будет содержать данные которые можно будет сразу увидеть после создания ресурсов (например ip адресс VPS)
4. **terraform.tfvars.sample** - Это образец из исходного файла **terraform.tfvars** который содержит значения переменных.

## Далее мы разберем основные нюансы при создании VPS и Records в Route53, все описывать нет смысла
* Куски кода из main.tf
```
resource "vscale_scalet" "task6" {
  count     = "${length(var.vscale_servers)}"
  name      = "${element(var.vscale_servers, count.index)}"
  make_from = "${var.vscale_make_from}"
  rplan     = "medium"
  location  = "spb0"
  ssh_keys  = ["${vscale_ssh_key.mykey.id}"]
}

resource "aws_route53_record" "records1" {
  zone_id = "${var.amz_53_zone_id}"
  name    = "${var.vscale_servers[0]}"
  type    = "A"
  ttl     = "300"
  records = ["${vscale_scalet.task5[0].public_address}"]
}
```
1. **count** - Указываем количество создаваемых VPS, количество будет браться из переменной **vscale_servers** с типом **"list"**. Пример содержимого переменной **vscale_servers = ["skensel-1", "skensel-2"]**
2. Имя для VPS берется из этой же переменной **vscale_servers**, **count.index** отвечает за выбор индекса VPS т.е первая VPS будет называться **skensel-1** а вторая **skensel-2**.
3. **resource "aws_route53_record" "records1"** - Создание ресурса route_53 (ресурсов по заданию два - они описанны в файле **main.tf**)
4. **zone_id** - Значение для этой переменной можно узнать командой **$ aws route53 list-hosted-zones | jq** (в данной команде jq использую для подсветки синтаксиса json и фильтра значений, мы обойдемся без фильтров так как данных мало)
5. **name** - Будет браться имя VPS по индексу и подставляться к значению Name в выводе который мы смотрели в предыдущем пункте (**$ aws route53 list-hosted-zones | jq**)
6. **type** - Выбор типа записи DNS, в нашем примере используется обычная запись типа **"A"** - соответствие между доменным именем и IP-адресом **(IPv4)**
7. **records** - Собственно сама запись, это ip адресс VPS(берется по индексу).

## Author

* **Ivan Kostin** - [Skensell](https://github.com/skensell201)

## Materials for creating instructions and project
* Docs [awscli route_53](https://docs.aws.amazon.com/cli/latest/reference/route53/index.html)
* Provider [AWS](https://www.terraform.io/docs/providers/aws/index.html)
* The [GOPATH](https://golang.org/doc/code.html#GOPATH) environment variable
* [Input Variables Terraform](https://www.terraform.io/docs/configuration/variables.html)

## License

Absolutely free =)

## Feedback

* Вы всегда можете написать [мне](mailto:skense1@yandex.ru) если будут вопросы или пожелания
