package karate;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVPrinter;
import org.apache.commons.csv.CSVRecord;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.*;
import java.nio.file.*;
import java.util.*;

public class CSVEditor {
    private static final Logger logger = LoggerFactory.getLogger(CSVEditor.class);

    public static void modifyCsv(String filePath, String documentColumn, String documentValue,
                                 String targetColumn, String newValue) throws IOException {

        // Leer el archivo y guardar la nueva informacion
        List<Map<String, String>> updatedRecords = new ArrayList<>();
        boolean recordFound = false;

        try (Reader reader = Files.newBufferedReader(Paths.get(filePath));
             CSVParser csvParser = CSVFormat.DEFAULT
                     .builder()
                     .setDelimiter(';')
                     .setHeader()
                     .setSkipHeaderRecord(true)
                     .setIgnoreSurroundingSpaces(true)
                     .build()
                     .parse(reader)) {

            List<String> headers = csvParser.getHeaderNames();

            if (!headers.contains(documentColumn) || !headers.contains(targetColumn)) {
                throw new IllegalArgumentException("Una de las columnas especificadas no existe en el archivo.");
            }

            for (CSVRecord record : csvParser) {
                Map<String, String> row = record.toMap();
                if (row.get(documentColumn).equals(documentValue)) {
                    recordFound = true;
                    row.put(targetColumn, newValue);
                }
                updatedRecords.add(row);
            }
        } catch (IOException e) {
            logger.error("Error al leer el archivo CSV: {}", e.getMessage(), e);
            ;
            throw new RuntimeException("Error al leer el archivo CSV: " + e.getMessage(), e);
        } catch (IllegalArgumentException e) {
            logger.error("Error en los parámetros: {}", e.getMessage(), e);
            throw new RuntimeException("Error en los parámetros: " + e.getMessage(), e);
        }

        if (!recordFound) {
            logger.error("No se encontró el valor {} en la columna {}", documentValue, documentColumn);
            throw new IllegalArgumentException("No se encontró el valor " + documentValue + " en la columna " + documentColumn);
        }

        // Reescribir el archivo CSV con las modificaciones
        try (Writer writer = Files.newBufferedWriter(Paths.get(filePath), StandardOpenOption.TRUNCATE_EXISTING);
             CSVPrinter csvPrinter = new CSVPrinter(writer, CSVFormat.DEFAULT
                     .builder()
                     .setDelimiter(';')
                     .setHeader(updatedRecords.get(0).keySet().toArray(new String[0]))
                     .build())) {

            for (Map<String, String> updatedRow : updatedRecords) {
                csvPrinter.printRecord(updatedRow.values());
            }
        } catch (IOException e) {
            logger.error("Error al escribir el archivo CSV: {}", e.getMessage(), e);
            throw new RuntimeException("Error al escribir el archivo CSV: " + e.getMessage(), e);
        }

        System.out.println("El archivo CSV ha sido modificado correctamente.");
    }
}