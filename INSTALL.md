# Installation and Deployment Steps

## Packaging the Lambda Function

To deploy the Lambda function, you need to create a deployment package (.zip file) containing the function code and its dependencies.

1.  **Install Dependencies Locally:**
    Install the required Python packages into a local directory named `package`. Run this command from the project root:
    ```bash
    uv pip install --target ./package -r requirements.txt
    ```
    *This ensures the dependencies are bundled with your code.*

2.  **Copy Function Code:**
    Copy the Lambda function code from the `src/functions/` directory into the `package` directory:
    ```bash
    cp -r src/functions/ig_post_extractor.py ./package/
    ```

3.  **Create the Zip Archive:**
    Navigate into the `package` directory and create a zip file containing its contents. The zip file will be created in the project root directory.
    ```bash
    cd package
    zip -r ../ig_post_extractor.zip .
    cd ..
    ```

After these steps, a `lambda_function.zip` file will be present in your project's root directory. This file is ready for deployment to AWS Lambda.

4. We can pull the zip package via Management Console for simplicity.