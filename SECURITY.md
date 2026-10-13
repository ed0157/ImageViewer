# Security policy

Image Viewer opens image files, so security reports are welcome.

## Reporting a vulnerability

Please **do not open a public issue** for a security problem.

Use GitHub's private reporting instead: open the **Security** tab of this repository and choose **Report a vulnerability**. Include the Image Viewer version, your macOS version, and the steps to reproduce. If a particular image file triggers it, describe the file rather than attaching anything private.

This is a small project maintained in spare time. Reports are handled on a best-effort basis, with no guaranteed response time.

## What is in scope

- A crafted image file that crashes the app or makes it run code.
- The app writing to, or changing, files when it should only be reading them.
- Problems in the build or release pipeline that could change what users download.

## Known limits (not vulnerabilities)

These are described in the README: the app is not notarized or sandboxed, and image decoding is done by macOS itself, so problems in the system's own image code belong to Apple.
