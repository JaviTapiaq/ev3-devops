#Javiera Tapia 20533877-2
#Joaquin Diez 21302876-6

FROM python:3.14-slim

#carpeta de trabajo
WORKDIR /app

#se copia al contenedor
COPY . .

#se instalan dependencias y pip-audit
RUN pip install --no-cache-dir flask pip-audit

#creacion de base de datos al construir la imagen
RUN python create_db.py

#puerto de Flask
EXPOSE 5000

#iniciar la app
CMD ["python", "vulnerable_flask_app.py"]
