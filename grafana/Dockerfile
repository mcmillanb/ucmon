FROM grafana/grafana:8.1.1

USER root

#ADD run.sh /run.sh
#RUN chmod +x /run.sh
RUN mkdir -p /opt/grafana/dashboards
ADD ["*.json", "/opt/grafana/dashboards/"]
ADD ["default-dashboard.yaml", "/etc/grafana/provisioning/dashboards/"]
#CMD ["/run.sh"]