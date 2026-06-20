FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
	PYTHONUNBUFFERED=1

WORKDIR /app

COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

RUN addgroup --system app && adduser --system --ingroup app app

COPY app/ .
RUN chown -R app:app /app
USER app

EXPOSE 8000

CMD ["gunicorn", "clinic_system.wsgi:application", "--bind", "0.0.0.0:8000"]