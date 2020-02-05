class KalmanFilter1D {
  // Process noise
  num R;
  // Measurement noise
  num Q;
  // State vector
  num A = 1;
  // Control vector
  num C = 1;
  // Measurement vector
  num B = 0;
  //
  num cov;
  // estimated signal without noise
  num x;

  /*
  * Create 1-dimensional kalman filter
  * @param  {Number} options.R Process noise
  * @param  {Number} options.Q Measurement noise
  * @param  {Number} options.A State vector
  * @param  {Number} options.B Control vector
  * @param  {Number} options.C Measurement vector
  * @return {KalmanFilter}
  */
  KalmanFilter1D(num r, num q) {
    this.R = r;
    this.Q = q;
  }

  /*
  * Filter a new value
  * @param  {Number} z Measurement
  * @param  {Number} u Control
  * @return {Number}
  */
  num filter(z, u) {
    if (this.x == null) {
      this.x = (1 / this.C) * z;
      this.cov = (1 / this.C) * this.Q * (1 / this.C);
    } else {
      // Compute prediction
      num predX = this.predict(u);
      num predCov = this.uncertainty();

      // Kalman gain
      num K = predCov * this.C * (1 / ((this.C * predCov * this.C) + this.Q));

      // Correction
      this.x = predX + K * (z - (this.C * predX));
      this.cov = predCov - (K * this.C * predCov);
    }

    return this.x;
  }

  /**
   * Predict next value
   * @param  {Number} [u] Control
   * @return {Number}
   */
  predict(num u) {
    return (this.A * this.x) + (this.B * u);
  }

  /**
   * Return uncertainty of filter
   * @return {Number}
   */
  uncertainty() {
    return ((this.A * this.cov) * this.A) + this.R;
  }

  /**
   * Return the last filtered measurement
   * @return {Number}
   */
  lastMeasurement() {
    return this.x;
  }

  /**
   * Set measurement noise Q
   * @param {Number} noise
   */
  setMeasurementNoise(noise) {
    this.Q = noise;
  }

  /**
   * Set the process noise R
   * @param {Number} noise
   */
  setProcessNoise(noise) {
    this.R = noise;
  }
}
