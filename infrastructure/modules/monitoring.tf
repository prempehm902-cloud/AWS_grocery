
resource "aws_cloudwatch_metric_alarm" "my_watch" {
  alarm_name                = "GroceryAlarm"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 300  # 5 minutes in seconds
  statistic                 = "Average"
  threshold                 = 95
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.topic.arn]
  dimensions = {
    InstanceId = aws_instance.app_server.id
  }
}