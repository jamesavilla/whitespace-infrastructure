[
  {
    "name": "whitespace-frontend-${environment}",
    "image": "${app_image}:${environment}",
    "cpu": ${fargate_cpu},
    "memory": ${fargate_memory},
    "networkMode": "awsvpc",
    "healthCheck": {
        "command": ["CMD-SHELL", "curl -f http://localhost:3000/health || exit 1"],
        "interval": 30,
        "timeout": 5,
        "retries": 10,
        "start_period": 60
    },
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "whitespace-frontend-${environment}",
          "awslogs-region": "${aws_region}",
          "awslogs-stream-prefix": "whitespace-frontend-log-stream-${environment}"
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
        "name": "NEXT_PUBLIC_API_HOST",
        "valueFrom": "arn:aws:secretsmanager:${aws_region}:${aws_account_id}:secret:whitespace-frontend-${environment}:NEXT_PUBLIC_API_HOST::"
      }
    ]
  }
]