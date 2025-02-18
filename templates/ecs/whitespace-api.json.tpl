[
  {
    "name": "whitespace-api-${environment}",
    "image": "${app_image}:${environment}",
    "cpu": ${fargate_cpu},
    "memory": ${fargate_memory},
    "networkMode": "awsvpc",
    "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 3,
        "start_period": 60
    },
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "whitespace-api-${environment}",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "whitespace-api-log-stream-${environment}"
        }
    },
    "portMappings": [
      {
        "containerPort": ${app_port},
        "hostPort": ${app_port}
      }
    ],
    "secrets": [
      {
        "name": "APP_PORT",
        "valueFrom": "arn:aws:secretsmanager:${aws_region}:${aws_account_id}:secret:whitespace-api-${environment}:APP_PORT::"
      },
      {
        "name": "AWS_REGION",
        "valueFrom": "arn:aws:secretsmanager:${aws_region}:${aws_account_id}:secret:whitespace-api-${environment}:AWS_REGION::"
      },
      {
        "name": "DB_DATABASE",
        "valueFrom": "arn:aws:secretsmanager:${aws_region}:${aws_account_id}:secret:whitespace-api-${environment}:DB_DATABASE::"
      },
      {
        "name": "DB_HOST",
        "valueFrom": "arn:aws:secretsmanager:${aws_region}:${aws_account_id}:secret:whitespace-api-${environment}:DB_HOST::"
      },
      {
        "name": "DB_PASSWORD",
        "valueFrom": "arn:aws:secretsmanager:${aws_region}:${aws_account_id}:secret:whitespace-api-${environment}:DB_PASSWORD::"
      },
      {
        "name": "DB_PORT",
        "valueFrom": "arn:aws:secretsmanager:${aws_region}:${aws_account_id}:secret:whitespace-api-${environment}:DB_PORT::"
      },
      {
        "name": "DB_SSL_CA",
        "valueFrom": "arn:aws:secretsmanager:${aws_region}:${aws_account_id}:secret:whitespace-api-${environment}:DB_SSL_CA::"
      },
      {
        "name": "DB_USER",
        "valueFrom": "arn:aws:secretsmanager:${aws_region}:${aws_account_id}:secret:whitespace-api-${environment}:DB_USER::"
      },
      {
        "name": "JWT_SECRET_KEY",
        "valueFrom": "arn:aws:secretsmanager:${aws_region}:${aws_account_id}:secret:whitespace-api-${environment}:JWT_SECRET_KEY::"
      },
      {
        "name": "ORIGIN",
        "valueFrom": "arn:aws:secretsmanager:${aws_region}:${aws_account_id}:secret:whitespace-api-${environment}:ORIGIN::"
      },
      {
        "name": "DB_MAX_CONNECTIONS",
        "valueFrom": "arn:aws:secretsmanager:${aws_region}:${aws_account_id}:secret:whitespace-api-${environment}:DB_MAX_CONNECTIONS::"
      },
      {
        "name": "FRONTEND_HOST",
        "valueFrom": "arn:aws:secretsmanager:${aws_region}:${aws_account_id}:secret:whitespace-api-${environment}:FRONTEND_HOST::"
      },
    ]
  }
]