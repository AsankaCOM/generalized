apiVersion: v1
kind: ServiceAccount
metadata:
  name: efs-provisioner
  namespace: ${efs_namespace}
--- 
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: efs-provisioner-runner
rules:
  - apiGroups: [""]
    resources: ["persistentvolumes"]
    verbs: ["get", "list", "watch", "create", "delete"]
  - apiGroups: [""]
    resources: ["persistentvolumeclaims"]
    verbs: ["get", "list", "watch", "update"]
  - apiGroups: ["storage.k8s.io"]
    resources: ["storageclasses"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["events"]
    verbs: ["create", "update", "patch"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: run-efs-provisioner
subjects:
  - kind: ServiceAccount
    name: efs-provisioner
    namespace: ${efs_namespace}
roleRef:
  kind: ClusterRole
  name: efs-provisioner-runner
  apiGroup: rbac.authorization.k8s.io
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: leader-locking-efs-provisioner
  namespace: ${efs_namespace}
rules:
  - apiGroups: [""]
    resources: ["endpoints"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: leader-locking-efs-provisioner
  namespace: ${efs_namespace}
subjects:
  - kind: ServiceAccount
    name: efs-provisioner
    namespace: ${efs_namespace}
roleRef:
  kind: Role
  name: leader-locking-efs-provisioner
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: efs-provisioner
  namespace: ${efs_namespace}
data:
  file.system.id: ${efs_id}
  aws.region: ${efs_region}
  provisioner.name: ${cluster_name}/aws-efs
--- 
kind: Deployment
apiVersion: extensions/v1beta1
metadata:
  name: efs-provisioner
  namespace: ${efs_namespace}
spec:
  replicas: 1
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: efs-provisioner
    spec:
      serviceAccount: efs-provisioner
      containers:
        - name: efs-provisioner
          image: quay.io/external_storage/efs-provisioner:${efs_provisioner_version}
          env:
            - name: FILE_SYSTEM_ID
              valueFrom:
                configMapKeyRef:
                  name: efs-provisioner
                  key: file.system.id
            - name: AWS_REGION
              valueFrom:
                configMapKeyRef:
                  name: efs-provisioner
                  key: aws.region
            - name: PROVISIONER_NAME
              valueFrom:
                configMapKeyRef:
                  name: efs-provisioner
                  key: provisioner.name
          volumeMounts:
            - name: pv-volume
              mountPath: /efshis
      volumes:
        - name: pv-volume
          nfs:
            server: ${efs_dns_name}
            path: /
---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: aws-efs
provisioner: ${cluster_name}/aws-efs
reclaimPolicy: Retain
---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: "gp2retain"
provisioner: kubernetes.io/aws-ebs
parameters:
  type: "gp2"
reclaimPolicy: Retain
mountOptions:
  - debug
---
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: "gp2-encrypted-retain"
provisioner: kubernetes.io/aws-ebs
parameters:
  encrypted: "true"
  type: "gp2"
reclaimPolicy: Retain
mountOptions:
  - debug
---