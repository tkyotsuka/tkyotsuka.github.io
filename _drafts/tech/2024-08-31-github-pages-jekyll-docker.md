---
layout: post
title: "Setting Up a Docker Environment for Local Jekyll Debugging on an M2 Mac"
date: 2024-08-31
categories: [jekyll, docker, macos]
---

When hosting your website with GitHub Pages, local debugging with Jekyll is essential. However, using Docker on an M2 Mac, which has an ARM64 architecture, requires special attention. In this guide, we'll walk through how to set up a Docker environment on an M2 Mac for local Jekyll debugging.

## Project Setup

First, let's look at the basic directory structure for your Jekyll project. Here is a simple example:

```bash
.
├── Dockerfile
├── Gemfile
├── _config.yml
└── index.md
```

### 1. Creating the Dockerfile

Create a `Dockerfile` with the following content. This will use the `jekyll/jekyll:latest` image as a base to set up the Jekyll environment.

```Dockerfile
# Use the jekyll/jekyll:latest image as the base
FROM jekyll/jekyll:latest

# Install Bundler if necessary
RUN gem install bundler

# Set the working directory
WORKDIR /srv/jekyll

# Copy the Gemfile and Gemfile.lock to the working directory
COPY Gemfile* /srv/jekyll/

# Install necessary gems
RUN bundle install

# Copy all files from the host to the container
COPY . /srv/jekyll

# Default command to start the Jekyll server
CMD ["jekyll", "serve", "--watch", "--host", "0.0.0.0"]
```

### 2. Creating the Gemfile

Next, create a `Gemfile` that defines the necessary Jekyll and related packages.

```ruby
source 'https://rubygems.org'
gem 'jekyll', '~> 3.9.2'
gem 'webrick'
gem 'github-pages', group: :jekyll_plugins
```

#### Gemfile Explanation

- **`source 'https://rubygems.org'`**: Specifies RubyGems as the source from which to fetch the gems.
- **`gem 'jekyll', '~> 3.9.2'`**: Specifies Jekyll version 3.9.2, allowing for the latest patch updates within the 3.9.x range.
- **`gem 'webrick'`**: Includes `webrick`, which is required to run Jekyll's development server on Ruby 3.x, where it's no longer part of the standard library.
- **`gem 'github-pages', group: :jekyll_plugins`**: This gem includes specific configurations and plugins used by GitHub Pages, allowing you to mimic the GitHub Pages environment locally.

### 3. Creating _config.yml and index.md

To keep things simple, here are basic examples of `_config.yml` and `index.md` files.

#### `_config.yml`

```yaml
title: My Site
```

#### `index.md`

```markdown
---
layout: default
title: Home
---

# Welcome to My Site
```

### 4. Building the Docker Image

Before running the container, you need to build the Docker image based on the `Dockerfile` you created. Run the following command in the directory containing the `Dockerfile`:

```bash
docker build -t my-jekyll-site .
```

- **`-t my-jekyll-site`**: Tags the built image with the name `my-jekyll-site`. You can use any name you prefer.
- **`.`**: Specifies the current directory as the build context, meaning Docker will use the `Dockerfile` in the current directory to build the image.

### 5. Troubleshooting: Permission Issues

When running Docker on an M2 Mac, you might encounter permission issues like the following:

#### Permission Error Example

```bash
chown: .jekyll-cache: Permission denied
```

#### Cause

This error occurs when the user ID (UID) and group ID (GID) of the host machine do not match those inside the Docker container. Typically, files and directories on the host machine are owned by the user who created them, but the process running inside the Docker container may have a different UID and GID, leading to permission errors.

### 6. Using the Docker Run Command

To solve this permission issue, you can use the `docker run` command with an additional option that ensures the process inside the container runs with the same UID and GID as the host user.

Run the following command to start the container:

```bash
docker run --rm -p 4000:4000 -v $(pwd):/srv/jekyll --user $(id -u):$(id -g) my-jekyll-site
```

#### Command Explanation

- **`--rm`**: Automatically removes the container when it exits, keeping your system clean.
- **`-p 4000:4000`**: Maps port 4000 of the host to port 4000 of the container, allowing you to access the Jekyll site at `http://localhost:4000`.
- **`-v $(pwd):/srv/jekyll`**: Mounts the current directory (`$(pwd)`) from the host to `/srv/jekyll` in the container, ensuring that changes made on the host are immediately reflected in the container.
- **`--user $(id -u):$(id -g)`**: Runs the container with the same UID and GID as the current user on the host, preventing permission issues.
- **`my-jekyll-site`**: Refers to the Docker image built from the earlier `Dockerfile`.

### 7. Why We Didn't Use Docker Compose

Docker Compose is a powerful tool that simplifies managing multiple containers and their configurations. However, in this case, we chose not to use Docker Compose for the following reason:

#### UID/GID Handling

Docker Compose does not support dynamically executing shell commands like `id -u` or `id -g` within its configuration file (`docker-compose.yml`). As a result, there's no clean way to automatically set the correct UID and GID for the container processes using Docker Compose alone.

##### If We Were to Use Docker Compose

If we wanted to use Docker Compose, one solution would be to manually set the UID and GID in an `.env` file and reference those in the `docker-compose.yml` file. Alternatively, a shell script could be used to export these values before running Docker Compose. However, these approaches are less streamlined and require manual updates.

### 8. Conclusion

This guide walked you through setting up a Docker environment for local Jekyll debugging on an M2 Mac. We specifically focused on using the `docker run` command to avoid permission issues and explained why Docker Compose was not ideal in this scenario. While Docker Compose is a valuable tool, it wasn't used here due to the lack of a clean solution for handling UID and GID.

Happy coding!
