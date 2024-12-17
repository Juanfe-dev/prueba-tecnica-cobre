function fn() {
  karate.log("Cargando configuraciones");


  karate.configure('connectTimeout', 5000);
  karate.configure('readTimeout', 5000);
  karate.configure('ssl', true);
  karate.configure('logPrettyResponse', true);

  const config = {
    api: {
      baseUrl: 'https://test-container-qa.prueba.co/v1/entity/novelties/'
    }
  };

  return config;
}