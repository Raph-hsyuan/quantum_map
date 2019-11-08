# -*- coding: utf-8 -*-
import numpy as np
from sklearn.cluster import DBSCAN
data=np.loadtxt("points.txt",delimiter=",")
estimator=DBSCAN(eps=80,min_samples=1,metric='euclidean')
estimator.fit(data)
print(estimator.labels_)