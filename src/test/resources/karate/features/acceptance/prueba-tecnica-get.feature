Feature: sample karate test script

  Background:
#    * configure retry = {count: 3, interval: 3000}
#    * def noveltyUuid = java.util.UUID.randomUUID().toString()
#    # La clase S3Util se encuentra en un gestor de librerías externo al proyecto
#    # Imaginemos que esta clase contiene la configuración y conexión de un cliente AWS, además los métodos para subir archivos a buckets S3
#    # También contiene un método para verificar si un archivo se encuentra dentro de un folder
#    * def S3Manager = Java.type('co.cobre.lib.qa.aws.S3Util')
#    * def S3ManagerInstance = new S3Manager()
#    * def SQSManager = karate.callSingle('classpath:karate/utilities/sqs/instances-sqs.js.js')
#    * def waitTime = function(seconds) { java.lang.Thread.sleep(seconds * 1000) }
#    # La clase FileUtils se encuentra en un gestor de librerías externo al proyecto
#    # Imaginemos que esta clase contiene métodos para tomar un archivo, renombrarlo y copiarlo en otra ruta
#    * def FileUtils = Java.type('co.cobre.lib.qa.util.FileUtils')
#    * def bucketName = 'test-automation-qa'
#    * def folderRecaudoFiles = 'files-to-cash-in'

  #   Este escenario esta destinado a mostrar la implementacion de la lectura y edicion del archivo CSV
  #   Esta implementacion puede ser adaptada a cualquier escenario en particular que requiera hacer ese proceso
  #   Por ejemplo modificar un CSV basado en la respuesta de una peticion HTTP
  @EditCSV
  Scenario Outline: Dado que tengo el documento del cliente, puedo modificar alguno de sus datos en el CSV
    * def random = read("classpath:karate/utilities/random/get-random-day.js")
    * def randomDay = random(1,30)
    * def CsvEditor = Java.type('karate.CSVEditor')
    * def filePath = '<currentFilePath>'+'<currentFileName>'
    * def documentColumn = 'Número de documento'
    * def documentValue = '000001'
    * def targetColumn = 'Fecha de Vencimiento'
    * def newValue = '2024-04-'+randomDay

    # Llamamos la clase CSVEditor y le mandamos la informacion para modificar basados en el documento del usuario
    # Considere usar el documento ya que es un id unico que permite identificarlo mas precisamente e incluso saber si existe en el archivo
    * CsvEditor.modifyCsv(filePath, documentColumn, documentValue, targetColumn, newValue)
    * print 'La fecha ha sido actualizada a '+ newValue
    Examples:
      | currentFilePath                     | currentFileName                         |
      | src/test/resources/karate/data/csv/ | recaudoTemplateDatosCorrectos.csv       |
      | src/test/resources/karate/data/csv/ | recaudoTemplateCaracteresEspeciales.csv |

  @S3UploadFile
  Scenario Outline: Dado que se carga un archivo de recaudo con datos correctamente con usuarios que recibirán un link de pago, al procesarse el archivo se persisten en BD los recaudo creados exitosamente
    # --------------------------------------------------------------- #
    * def noveltyUuid = karate.get('noveltyUuid')
    * def inputClientCode = karate.get('clientCode')
    * print "El uuid de la novedad es: " + noveltyUuid
    * def fileExtension = ".csv"
    * def fullFileName = noveltyUuid+fileExtension
    # --------------------------------------------------------------- #
    * def renameFile = FileUtils.renameFile(currentFilePath, currentFileName, newPathNewFile, noveltyUuid, fileExtension)
    * waitTime(3)
    * print "El resultado de renombrar el archivo es: " + renameFile
    * match renameFile == true
    # --------------------------------------------------------------- #
    * print "El bucket es: " + bucketName
    * print "El folder  es: " + folderRecaudoFiles
    * S3ManagerInstance.uploadFileToBucket(bucketName, folderRecaudoFiles, fullFileName, newPathNewFile)
    * waitTime(3)
    # --------------------------------------------------------------- #
    * def fileExist = S3ManagerInstance.doesFileExist(bucketName, folderRecaudoFiles, fullFileName)
    * print "La existencia del archivo es: " + fileExist
    * match fileExist == true
    # --------------------------------------------------------------- #
    * def variableMapToReplaceInQueueMessageBody =
    """
    {
    "fileName": '#(fullFileName)',
    "workplacebankCode": '#(inputClientCode)',
    "bucketName": '#(bucketName)'
    }
    """
    * SQSManager.sendMessageToQueue('<jsonFileSqsEvents>', 'testing-recaudo-qa.fifo', variableMapToReplaceInQueueMessageBody, '<pathJsonFileSqsEvents>')
    * waitTime(8)

    Examples:
      | pathJsonFileSqsEvents                    | jsonFileSqsEvents |
      | src/test/resources/karate/utilities/sqs/ | queueEvent.json   |


  # --------------------------------------------------------------- #
  # Uso de API REST para obtener información de las novedades
  @regression
  Scenario Outline: Consultar informacion de las novedades
    * def uploadS3File = call read('prueba-tecnica-get.feature@S3UploadFile') { uuid: noveltyUuid, clientCode : clientCode }
    Given url api.baseUrl + noveltyUuid
    And header X-WorkplaceBankCode = '<clientCode>'
    And retry until responseStatus == 200 && response.content != []
    When method get
    Then status 200
    * match getNovelty.status == '<noveltyStatus>'
    * match getNovelty.totalNovelties == '<registerTotal>'
    * match getNovelty.validationError == <validationErrorNumber>
    * match getNovelty.created == <createdNumber>
    * waitTime(3)

    Examples:
      | clientCode | noveltyStatus | registerTotal | validationErrorNumber | createdNumber |
      | TEST01     | VALIDATED     | 3             | '0'                   | '3'           |
      | TEST02     | VALIDATED     | 2             | '2'                   | '0'           |

  # --------------------------------------------------------------- #
  # Uso de API REST para obtener información de las novelty-details
  @regression
  Scenario Outline: Consultar detalle de las novedades
    * def result = call read('prueba-tecnica-get.feature@S3UploadFile') { uuid: noveltyUuid, clientCode : clientCode  }
    * def dataWithExpectedInformation = karate.read("classpath:karate/data/json/response/" + '<jsonDataWithExpectedInformation>')
    * def pageInt = parseInt('<page>')
    * def sizeInt = parseInt('<size>')
    Given url api.baseUrl + noveltyUuid
    And header X-WorkplaceBankCode = '<clientCode>'
    And params {page: '#(pageInt)', size: '#(sizeInt)'}
    And retry until responseStatus == 200 && response.content != []
    When method get
    Then status 200
    * def content = response.content
    * match getNoveltyDetails.content contains deep dataWithExpectedInformation
    * match response contains deep { "cashInInfo": { "status": "<expectedStatus>" } }

    Examples:
      | clientCode | jsonDataWithExpectedInformation            | page | size | expectedStatus   |
      | TEST01     | respuestaEsperadaDatosCorrectos.json       | 1    | 3    | CREATED          |
      | TEST02     | respuestaEsperadaCaracteresEspeciales.json | 1    | 2    | VALIDATION_ERROR |